include("JuliaParser.jl")

import Main.JuliaParser

macro my_mac(expr)
    #JuliaParser.print_tree(expr)
    JuliaParser.test()
end

@my_mac begin
    x = 2 * 2
end
