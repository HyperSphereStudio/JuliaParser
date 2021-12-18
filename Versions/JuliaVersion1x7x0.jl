export JuliaVersion1x7x0

struct JuliaVersion1x7x0 <: AbstractJuliaVersion
    Core::JModule
    Any::JType

    function JuliaVersion1x7x0()
        Core = JModule()
        Any = JType(:Any, Core, [])

        new(Core, Any)
    end
end
