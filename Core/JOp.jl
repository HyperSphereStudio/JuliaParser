export JOp, JOpTest

export FuncCall

abstract type JOp <: AbstractJuliaObject end

struct FuncCall <: JOp
    InvokingFunction::Symbol
    Arguments::Vector{JExpr}

    function emit(code::FuncCall, version::AbstractJuliaVersion)
        Expr(:call, code.InvokingFunction)
        for arg in code.Arguments
            push!(emit(arg))
        end
    end

    function reload(code::FuncCall, version::AbstractJuliaVersion)

    end
end



function JOpTest(version::AbstractJuliaVersion)

end
