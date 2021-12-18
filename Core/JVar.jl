export JVar, JVarTest

mutable struct JVar <: AbstractJuliaObject
    Name::Symbol
    Module::JModule
    Type::JType

    JVar(Name::Symbol, Module::JModule, Type::JType) = new(Name, Module, Type)

    function JVar(code, Module::JModule, version::AbstractJuliaVersion)
        if code isa Symbol
            return new(code, Module, version.Any)
        end
        return new(code.args[1], Module, parse)
    end

    Base.isequal(var1::JVar, var2::JVar) = var1.Name == var2.Name && var1.Module == var2.Module && var1.Type == var2.Type
end

function verifyvardef(code, Module::JModule, version::AbstractJuliaVersion)
    return code isa Symbol || code.head == :(::)
end

function emit(var::JVar, version::AbstractJuliaVersion)
    if var.Type == version.Any
        return var.Name
    end
    return Expr(:(::), var.Name, emit(var.Type))
end

function JVarTest()
    @assert emit(parse(:(x::Vector{Integer}))) == :(x::Vector{Integer})
    @assert emit(parse(:(x))) == :(x)

end
