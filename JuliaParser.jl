module JuliaParser

    abstract type AbstractJuliaVersion end
    abstract type AbstractJuliaObject end
    abstract type AbstractJuliaParser end

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

    struct ParserException <: Exception
        msg::String
        ParserException(msg::String) = new(msg)
        Base.print(io::IO, p::ParserException) = print(io, string(p))
        Base.string(p::ParserException) = p.msg
    end

    export ParserException, AbstractJuliaVersion, AbstractJuliaObject, parse, emit, reload, reveal, lower

    include("Utils.jl")
    include("Versions/JuliaVersion1x7x0.jl")
    include("Core/JType.jl")
    include("Core/JContext.jl")
    include("Core/JVar.jl")

    latest_version = JuliaVersion1x7x0()

    emit(type::AbstractJuliaObject, context) = ()
    isnull(type::AbstractJuliaObject) = false
    reload(type::JType, context) = ()

    function parse(code::Expr, mod::Module; version::AbstractJuliaVersion=latest_version)
        version.Parser(macroexpand(mod, code))
    end

    function test(io::IO=stdout, version::AbstractJuliaVersion=latest_version)
        context = JContext(version)
        JTypeTest(io, context)
        JVarTest(io, context)
    end

    Base.print(io::IO, jobj::AbstractJuliaObject) = print(io, string(jobj, 0))
end
