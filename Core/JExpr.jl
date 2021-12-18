export JExpr, JExprTest

mutable struct JExpr <: AbstractJuliaObject
    
end

function emit(expr::JExpr, version::AbstractJuliaVersion)

end

function reload(expr::JExpr, version::AbstractJuliaVersion)

end

function JExprTest(version::AbstractJuliaVersion)

end
