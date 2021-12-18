module JuliaParser

    abstract type AbstractJuliaVersion end
    abstract type AbstractJuliaObject end
    struct ParserException <: Exception
        msg::String
        ParserException(msg::String) = new(msg)
        Base.print(io::IO, p::ParserException) = print(io, string(p))
        Base.string(p::ParserException) = p.msg
    end

    export ParserException, AbstractJuliaVersion, AbstractJuliaObject, parse, emit

    latest_version = JuliaVersion1x7x0()

    include("Utils.jl")
    include("Core/JModule.jl")
    include("Core/JType.jl")
    include("Core/JField.jl")
    include("Core/JMethod.jl")
    include("Core/JStruct.jl")



    function parse(code::Expr, version::AbstractJuliaVersion=JuliaVersion1x7x0)::AbstractJuliaObject
        
    end

    function emit(jobj::AbstractJuliaObject, version::AbstractJuliaVersion=JuliaVersion1x7x0)::Expr

    end

    Base.print(io::IO, jobj::AbstractJuliaObject) = print(io, string(jobj))
    Base.string(jobj::AbstractJuliaObject) = print_tree(emit(jobj))


    function test()
        JTypeTest()
        JVarTest()
    end
end

using Main.JuliaParser
