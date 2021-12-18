export JModule, JModuleTest, null_mod, add_type, remove_type

mutable struct JModule <: AbstractJuliaObject
    Name::Symbol
    File::String
    Types::Vector{AbstractJuliaObject}
    Globals::Vector{AbstractJuliaObject}
    Methods::Vector{AbstractJuliaObject}
    Structs::Vector{AbstractJuliaObject}

    JModule(Name, File, Types, Globals, Methods, Structs) = new(Name, File, Types, Globals, Methods, Structs)
    
    JModule(Name; File = "", Types::Vector{AbstractJuliaObject} = [], Globals::Vector{AbstractJuliaObject} = [],
        Methods::Vector{AbstractJuliaObject} = [], Structs::Vector{AbstractJuliaObject} = []) = JModule(Name, Field, Globals, Methods, Structs)
end

function null_mod(jmod::JModule)::Bool
    return jmod.Name == :null_mod
end

function remove_type(jmod::JModule, type::AbstractJuliaObject)::Int64
    out = findfirst(jmod.Types, type)
    if out == nothing
        jmod.Types[out] = null_module
        deleteat!(jmod.Types, out)
        return true
    end
    false
end

function add_type(jmod::JModule, type::AbstractJuliaObject)::Int64
    out = findfirst(jmod.Types, type)
    if out == nothing
        append!(jmod.Types, type)
        type.Module = jmod
        return length(jmod.Types)
    end
    out
end

function reload(jmod::JModule, version::AbstractJuliaVersion)
    for type in jmod.Types
        type.Module = jmod
        reload(type, version)
    end
    for glob in jmod.Globals
        glob.Module = jmod
        reload(glob, version)
    end
    for method in jmod.Methods
        method.Module = jmod
        reload(method, version)
    end
    for strc in jmod.Structs
        strc.Module = jmod
        reload(strc, version)
    end
end

function emit(jmod::JModule, version::AbstractJuliaVersion)
    block = Expr(:block)
    mod = Expr(:module, Name, block)

    mod
end

function JModuleTest(version::AbstractJuliaVersion)

end
