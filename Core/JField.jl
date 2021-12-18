export JField, JFieldTest

mutable struct JField <: AbstractJuliaObject
    Name::String
    Type::JType
    Struct::AbstractJuliaObject
end

function emit(field::JField, version::AbstractJuliaVersion)

end

function reload(field::JField, version::AbstractJuliaVersion)

end

function JFieldTest(version::AbstractJuliaVersion)

end
