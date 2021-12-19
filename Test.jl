include("JuliaParser.jl")

import Main.JuliaParser

macro my_mac(expr)
    #JuliaParser.parse(expr, @__MODULE__)
    JuliaParser.test()
end

@my_mac begin
    x::Integer
    x2::Integer
end
