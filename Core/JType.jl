export JType, JTypeTest, parsetype

mutable struct JType <: AbstractJuliaObject
    Name::Symbol
    Module::JModule
    Types::Vector{AbstractJuliaObject}

    JType(Name::Symbol, Module::JModule, Types::Vector{AbstractJuliaObject}) = new(Name, Module, Types)

    function JType(code, Module::JModule, version::AbstractJuliaVersion)
        if code isa Symbol
            return new(code, Module, [])
        end

        Name = search_forany_symbol(code.args[1])
        Types::Vector{AbstractJuliaObject} = []
        for i in 2:length(code.args)
            item = code.args[i]
            append!(Types, search_forany_symbol(code.args[i]))
        end
        return new(Name, Module, Types)
    end

    Base.isequal(type1::JType, type2::JType) = type1.Name == type2.Name && type1.Module == type2.Module && issetequal(type1.Types, type2.Types)
end

function emit(type::JType, version::AbstractJuliaVersion)
    if length(type.Types) == 0
        return type.Name
    end
    curly_block = Expr(:curly, type.Name)
    for item in type.Types
        push!(curly_block, emit(item))
    end
    curly_block
end


function JTypeTest()

end
