export JType

mutable struct JType <: AbstractJuliaObject
    name::Symbol
    typeArgs::Vector{JType}

    JType() = new(:null, [])

    function JType(expr, context)
        out = push!(context, JType())
        if istype(expr, context)
            out.name = expr
            return out
        else
            out.name = expr.args[1]
            for i in 2:length(expr.args)
                push!(out.typeArgs, parse(expr.args[i], context))
            end
            return out
        end
    end
end

function emit(type::JType, context)
    reload(type, context)
    if length(type.typeArgs) > 0
        expr = Expr(:curly, type.name)
        for arg in type.typeArgs
            push!(expr.args, emit(arg, context))
        end
        return expr
    else
        return type.name
    end
end

isnull(type::JType) = type.name == :null

function reload(type::JType, context)
    for t in type.typeArgs
        reload(t, context)
    end
end

istypedargtype(expr, context) = isexpr(expr, :curly) && expr.args[1] isa Symbol
istype(expr, context) = expr isa Symbol
isanytype(type::JType) = type.name == :Any

function isjtype(expr, context)
    return istype(expr, context) || istypedargtype(expr, context)
end


function JTypeTest(io::IO, context)
    clear!(context)

    #Expr Checking
    println(io, "Type Expr Parsing Check Starting")
    @assert istype(:x, context) "Is Any Type Check Fail"
    @assert istype(:Vector, context) "Typed Arg Type Check Fail 1"
    @assert istypedargtype(:(Vector{Int, Int32}), context) "Typed Arg Type Check Fail 2"
    println(io, "Type Expr Parsing Check Complete")


    #Gen Expr Checking
    println(io, "Type Expr Emit Checking Starting")
    @assert emit(JType(:x, context), context) == :x "Any Type Expr Rep Failed: "
    @assert emit(JType(:Vector, context), context) == :Vector "Typed Arg Expr Rep Failed 1"
    @assert emit(JType(:(Vector{Int, Int32}), context), context) == :(Vector{Int, Int32}) "Typed Arg Expr Rep Failed 2"
    println(io, "Type Expr Emit Checking Complete")
end
