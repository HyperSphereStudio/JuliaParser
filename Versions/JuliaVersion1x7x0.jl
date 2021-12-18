export JuliaVersion1x7x0

struct JuliaVersion1x7x0 <: AbstractJuliaVersion
    Core::JModule
    Any::JType

    function JuliaVersion1x7x0()
        Any = JType(:Any)
        Core = JModule(:Core, "Core.jl", Types = [Any])



        out = new(Core, Any)
        reload(Core, out)
    end
end
