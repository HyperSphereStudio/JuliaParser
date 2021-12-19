export JVar

mutable struct JVar <: AbstractJuliaObject
    name::Symbol
    type::JType

    JVar() = new(:null, JType())

    function JVar(expr, context)
        out = push!(context, JVar())
        if isanyvar(expr, context)
            out.name = expr
            out.type = JType(:Any, context)
            return out
        else
            out.name = expr.args[1]
            out.type = parse(expr.args[2], context)
            return out
        end
    end
end

isnull(type::JVar) = type.name == :null
istypedvar(expr, context) = isexpr(expr, :(::))
isanyvar(expr, context) = expr isa Symbol
reload(var::JVar, context) = reload(var.type, context)

function emit(var::JVar, context)
    reload(var, context)
    if isanytype(var.type)
        return var.name
    else
        return Expr(:(::), var.name, emit(var.type, context))
    end
end

function isjvar(expr, context)
    return (isanyvar(expr, context) || istypedvar(expr, context)) && !(last(context) isa JVar || last(context) isa JType)
end

function JVarTest(io::IO, context)
    clear!(context)
    #Expr Checking
    println(io, "Var Expr Parsing Check Starting")
    @assert isanyvar(:x, context) "Var Any Type Check Fail"
    @assert istypedvar(:(x::Integer), context) "Var Typed Check Fail"
    println(io, "Var Expr Parsing Check Complete")

    #Gen Expr Checking
    println(io, "Var Expr Emit Checking Starting")
    @assert emit(JVar(:x, context), context) == :x "Any Type Expr Rep Failed: "
    @assert emit(JVar(:(x::Vector), context), context) == :(x::Vector) "Typed Arg Expr Rep Failed 1"
    @assert emit(JVar(:(x::Vector{Int, Int32}), context), context) == :(x::Vector{Int, Int32}) "Typed Arg Expr Rep Failed 2"
    println(io, "Var Expr Emit Checking Complete")
end
