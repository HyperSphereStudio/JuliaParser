export JCode, JCodeTest

mutable struct JCode <: AbstractJuliaObject

end

function emit(code::JCode, version::AbstractJuliaVersion)

end

function reload(code::JCode, version::AbstractJuliaVersion)

end

function JCodeTest(version::AbstractJuliaVersion)

end
