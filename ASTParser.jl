export @print_tree, print_tree, SearcherSettings, SearcherResult, search_expr,
       search_forany_heads, search_forany_symbols, search_for_symbols, get_var_name, get_var_type,
       search_for_heads

macro print_tree(expr::Expr)
    print_tree(expr)
end

function print_tree(expr::Expr; level::Int64=0)
    println(repeat("\t", level), expr.head)
    for item in expr.args
        if item isa Expr
            print_tree(item, level=level + 1)
        else
            println(repeat("\t", level + 1), item)
        end
    end
end

struct SearcherSettings
    "Returns Bool. Takes in any"
    fireChecker::Function
    shallowSearchFirst::Bool
    skip_count::Int64
    curr_count::Int64

    SearcherSettings(fireChecker::Function, shallowSearchFirst::Bool, skip_count::Int64) = new(fireChecker, shallowSearchFirst, skip_count, 0)
end

struct SearcherResult
    parent::Expr
    pindex::Int32
    result

    SearcherResult(parent::Expr, pindex) = new(parent, Int32(pindex), parent.args[pindex])
    SearcherResult(parent::Expr, pindex::Int64, result) = new(parent, Int32(pindex), result)
end

function contains(t::Array{T, 1}, sym::T)::Bool where T
    for item in t
        if item == sym
            return true
        end
    end
    return false
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
