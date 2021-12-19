export JuliaParser1x7x0

struct JuliaParser1x7x0 <: AbstractJuliaParser
    JuliaParser1x7x0() = new()

    function (parser::JuliaParser1x7x0)(code, context)
        if isjvar(code, context)
            return JVar(code, context)
        end
        if isjtype(code, context)
            return JType(code, context)
        end
    end
end
