export print_tree, @print_tree, isexpr

isexpr(ex, sym::Symbol)::Bool = ex isa Expr && ex.head == sym

macro print_tree(expr)
    print_tree(expr)
end

function print_tree(expr; level::Int64=0)
    if expr isa Symbol
        println(expr)
        return
    end
    println(repeat("\t", level), expr.head)
    for item in expr.args
        if item isa Expr
            print_tree(item, level=level + 1)
        else
            println(repeat("\t", level + 1), item)
        end
    end
end

function contains(t::Array{T, 1}, sym::T)::Bool where T
    for item in t
        if item == sym
            return true
        end
    end
    return false
end

function tab(level, str...)
    header = repeat("\t", level)
    for s in str
        header *= s
    end
    header
end

function tabln(level, str...)
    header = repeat("\t", level)
    for s in str
        header *= Base.string(s)
    end
    header * "\n"
end
