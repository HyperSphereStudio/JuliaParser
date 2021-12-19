export JuliaVersion1x7x0

include("../Parsers/JuliaParser1x7x0.jl")

struct JuliaVersion1x7x0 <: AbstractJuliaVersion
    Parser::JuliaParser1x7x0
    function JuliaVersion1x7x0()
        new(JuliaParser1x7x0())
    end
end


function search_expr(expr::Expr, settings::SearcherSettings)
    if settings.fireChecker(expr, 0, expr)
        if settings.skip_count <= settings.curr_count
            return SearcherResult(Expr(:nothing, expr), 1, expr)
        else
            settings.curr_count += 1
        end
    end

    if settings.shallowSearchFirst
        for i in 1:length(expr.args)
            if settings.fireChecker(expr, i, expr.args[i])
                if settings.skip_count <= settings.curr_count
                    return SearcherResult(expr, i)
                else
                    settings.curr_count += 1
                end
            end
        end
        for i in 1:length(expr.args)
            if expr.args[i] isa Expr
                out = search_expr(expr.args[i],  settings)
                if out != nothing
                    return out
                end
            end
        end
    else
        for i in 1:length(expr.args)
            if settings.fireChecker(expr, i, expr.args[i])
                if settings.skip_count <= settings.curr_count
                    return SearcherResult(expr, i)
                else
                    settings.curr_count += 1
                end
            else
                if expr.args[i] isa Expr
                    out = search_expr(expr.args[i],  settings)
                    if out != nothing
                        return out
                    end
                end
            end
        end
    end

    return nothing
end


"Takes in call function that takes in (parent, idx, incoming) that calls on all heads except exception heads"
function search_forany_heads(expr::Expr, call_function::Function; exceptionHeads::Array{Symbol, 1}=Symbol[:LineNumberNode], shallowSearchFirst=false, skip_count=0)
    search_expr(expr, SearcherSettings(
        function (parent, idx, incoming)
            if incoming isa Expr && !contains(exceptionHeads, incoming.head)
                call_function(parent, idx, incoming)
            end
            return false
        end
    , shallowSearchFirst, skip_count))
end


"""Search for any heads except the exception heads. """
function search_forany_heads(expr::Expr; exceptionHeads::Array{Symbol, 1}=Symbol[:LineNumberNode], shallowSearchFirst=false, skip_count=0)
    search_expr(expr, SearcherSettings(
        function (parent, idx, incoming)
            return incoming isa Expr && !contains(exceptionHeads, incoming.head)
        end
    , shallowSearchFirst, skip_count))
end

"Takes in call function that takes in (parent, idx, incoming) that calls on all specified heads"
function search_for_heads(expr::Expr, call_function::Function, findSymbols::Array{Symbol, 1}; shallowSearchFirst=false, skip_count=0)
    search_expr(expr, SearcherSettings(
        function (parent, idx, incoming)
            if incoming isa Expr && contains(findSymbols, incoming.head)
                call_function(parent, idx, incoming)
            end
            return false
        end
    , shallowSearchFirst, skip_count))
end

"""Search for only a few heads"""
function search_for_heads(expr::Any, findSymbols::Array{Symbol, 1}; shallowSearchFirst=false, skip_count=0)
    search_expr(expr, SearcherSettings(
        function (parent, idx, incoming)
            return incoming isa Expr && contains(findSymbols, incoming.head)
        end
    , shallowSearchFirst, skip_count))
end


"Takes in call function that takes in (parent, idx, incoming). "
function search_forany_symbols(expr::Expr, call_function::Function; exceptionSymbols::Array{Symbol, 1}=Symbol[:LineNumberNode], shallowSearchFirst=false, skip_count=0)
    if expr isa Symbol
        if !contains(exceptionSymbols, expr)
            return SearchResult(:(nothing), 0, expr)
        end
        return nothing
    else
        return search_expr(expr, SearcherSettings(
            function (parent, idx, incoming)
                if incoming isa Symbol && !contains(exceptionSymbols, incoming)
                    call_function(parent, idx, incoming)
                end
                return false
            end
        , shallowSearchFirst, skip_count))
    end
end

"""Search for any symbol except the exception symbols. """
function search_forany_symbols(expr::Any; exceptionSymbols::Array{Symbol, 1}=Symbol[:LineNumberNode], shallowSearchFirst=false, skip_count=0)
    if expr isa Symbol
        if !contains(exceptionSymbols, expr)
            return SearchResult(:(nothing), 0, expr)
        end
        return nothing
    else
        return search_expr(expr, SearcherSettings(
            function (parent, idx, incoming)
                return incoming isa Symbol && !contains(exceptionSymbols, incoming)
            end
        , shallowSearchFirst, skip_count))
    end
end


"""Takes in call function that takes in (parent, idx, incoming). Search for only a few symbols"""
function search_for_symbols(expr, findSymbols::Array{Symbol, 1}; shallowSearchFirst=false, skip_count=0)
    if expr isa Symbol
        if contains(findSymbols, expr)
            return SearchResult(:(nothing), 0, expr)
        end
        return nothing
    else
        return search_expr(expr, SearcherSettings(
            function (parent, idx, incoming)
                return incoming isa Symbol && contains(findSymbols, incoming)
            end
        , shallowSearchFirst, skip_count))
    end
end

"""Search for only a few symbols"""
function search_for_symbols(expr, call_function::Function, findSymbols::Array{Symbol, 1}; shallowSearchFirst=false, skip_count=0)
    if expr isa Symbol
        if contains(findSymbols, expr)
            return SearchResult(:(nothing), 0, expr)
        end
        return nothing
    else
        return search_expr(expr, SearcherSettings(
            function (parent, idx, incoming)
                if incoming isa Symbol && contains(findSymbols, incoming)
                    call_function(parent, idx, incoming)
                end
                return false
            end
        , shallowSearchFirst, skip_count))
    end
end

function is_short_function_def(@nospecialize(ex))
    isexpr(ex, :(=)) || return false
    while length(ex.args) >= 1 && isa(ex.args[1], Expr)
        (ex.args[1].head === :call) && return true
        (ex.args[1].head === :where || ex.args[1].head === :(::)) || return false
        ex = ex.args[1]
    end
    return false
end

is_function_def(@nospecialize(ex)) =
    return isexpr(ex, :function) || is_short_function_def(ex) || isexpr(ex, :->)

function remove_linenums!(ex::Expr)
    if ex.head === :block || ex.head === :quote
        # remove line number expressions from metadata (not argument literal or inert) position
        filter!(ex.args) do x
            isa(x, Expr) && x.head === :line && return false
            isa(x, LineNumberNode) && return false
            return true
        end
    end
    for subex in ex.args
        subex isa Expr && remove_linenums!(subex)
    end
    return ex
end    
