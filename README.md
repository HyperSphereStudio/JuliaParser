# JuliaParser


Julia AST Engineering Library.


Parsers Julia AST into an efficient organized structure of Modules, Structures, Fields etc that can be easily modified. This can then be reemitted back into Julia AST.

Why: To perform complex code analysis without having to worry about syntax of Julia



Example:
    using JuliaParser

    macro my_macro(expr)
        parse_result = parse(expr)

        parse_result.struct[1].Name = :TestStruct2
        reload(parse_result)

        emit(parse_result)
    end

    @my_macro begin
        struct TestStruct{T}
            f::T
            TestStruct(v::T) = new(v)
        end
    end

    Will Return:
        struct TestStruct2{T}
            f::T
            TestStruct2(v::T) = new(v)
        end
