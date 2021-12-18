export JMethod, JMethodTest

mutable struct JMethod <: AbstractJuliaObject
    Name::String
    Module::JModule
    Locals::Vector{JVar}
end

function emit(method::JMethod, version::AbstractJuliaVersion)

end

function reload(method::JMethod, version::AbstractJuliaVersion)
    for l in method.Locals
        reload(l, version)
    end
end

function JMethodTest(version::AbstractJuliaVersion)

end
