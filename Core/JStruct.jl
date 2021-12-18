export JStruct, JStructTest

mutable struct JStruct <: AbstractJuliaObject

end


function emit(jstruct::JStruct, version::AbstractJuliaVersion)

end

function JStructTest(version::AbstractJuliaVersion)

end
