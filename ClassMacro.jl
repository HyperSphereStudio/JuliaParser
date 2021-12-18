export @class, @mclass, super

"""Has mutable super class"""
macro mclass(class_info::Expr, body::Expr)
    gen_class(true, class_info, body)
end

"""Has super class"""
macro class(class_info::Expr, body::Expr)
    gen_class(false, class_info, body)
end

"""No Super Class. Is mutable"""
macro mclass(name::Symbol, body::Expr)
    gen_class(true, name, body)
end

"""No Super Class"""
macro class(name::Symbol, body::Expr)
    gen_class(false, name, body)
end


"Call parent super method"
function super(args...)

end

macro class(type::Symbol)
    return Symbol(string(type) * "Class")
end


struct ParserException <: Exception
    msg::String
    ParserException(msg::String) = new(msg)
    Base.print(io::IO, e::ParserException) = print(io, string(e))
    Base.string(e::ParserException) = "ParserException:" * msg
end

function gen_class(is_mut::Bool, class_info, body::Expr)
    structExpr::Expr = Expr(:struct, is_mut)
    expr::Expr = Expr(:block, structExpr)
    has_clazz_super::Bool = false
    #The Class Name Symbol
    clazz::Symbol = :nothing

    #The Expression Representing Name and Generic Types for Abstract Class
    aclazz = nothing

    #The expression Representing Name and Generic Types for Super Class
    sclazz = nothing

    #The actual super type
    stype = nothing

    #The Expression representing the struct type information
    clazz_info_expr = deepcopy(class_info)

    #When the class info is simple
    if class_info isa Symbol
        aclazz = Symbol(string(class_info) * "Class")
        clazz = class_info
        clazz_info_expr = Expr(:(<:), class_info, aclazz)
        insert!(expr.args, 1, esc(:(abstract type $aclazz end)))
    else
        #Expression representing the abstract type information when the type is a symbol
        aclazz_parent_expr::Expr = class_info
        aclazz_sym_idx::Int64 = 1
        clazz_res_parent_expr = class_info
        clazz_sym_idx::Int64 = 1

        #Find the struct name when it isnt a simple symbol
        if class_info.args[1] isa Expr
            aclazz_res::SearcherResult = search_forany_symbols(class_info.args[1])
            aclazz_parent_expr = aclazz_res.parent
            aclazz_sym_idx = aclazz_res.pindex
        end

        clazz = aclazz_parent_expr.args[aclazz_sym_idx]
        #Create new class from incoming type and replace
        aclazz_parent_expr.args[aclazz_sym_idx] = Symbol(string(aclazz_parent_expr.args[aclazz_sym_idx]) * "Class")
        clazz_res_parent_expr.args[clazz_sym_idx] = aclazz_parent_expr.args[aclazz_sym_idx]
        aclazz = class_info.args[1]

        #Check if the class extends anything (Super Type)
        if class_info.args[2] isa Expr && class_info.head == :(<:)
            #Super class information when it is a simple symbol
            sclazz_parent_expr::Expr = class_info
            sclazz_sym_idx::Int64 = 2

            #Find the super type name when it isnt a simple symbol

            if class_info.args[2] isa Expr
                sclazz_res = search_forany_symbols(clazz_info_expr.args[2])
                sclazz_parent_expr = sclazz_res.parent
                sclazz_sym_idx = sclazz_res.pindex
            end

            #Look for the class super type, if it exists then get the type object, else return the non abstract type
            try
                asym = asym::Symbol = Symbol(string(sclazz_parent_expr.args[sclazz_sym_idx]) * "Class")
                stype = eval(asym)
                sclazz_parent_expr.args[sclazz_sym_idx] = asym
                has_clazz_super = true
            catch
                stype = eval(sclazz_parent_expr.args[sclazz_sym_idx])
            end

            sclazz = clazz_info_expr.args[2]
            clazz_info_expr.args[2] = aclazz_parent_expr
            insert!(expr.args, 1, esc(:(abstract type $aclazz_parent_expr <: $sclazz end)))
            sclazz = search_forany_symbols(sclazz).result
        else
            insert!(expr.args, 1, esc(:(abstract type $aclazz_parent_expr end)))
        end

        class_info = class_info.args[1]
    end

    structBlock = Expr(:block)

    #Remove the type extensions from abstract type
    search_symbols = [:(<:)]
    for i in 1:length(aclazz_parent_expr.args)
        item = aclazz_parent_expr.args[i]
        if item isa Expr
            res = search_for_heads(item, search_symbols).result
            if res != nothing
                aclazz_parent_expr.args[i] = res.args[1]
            end
        end
    end

    #Define the Structure Name and Extension
    push!(structExpr.args, clazz_info_expr)

    #Create the structure Block
    push!(structExpr.args, structBlock)

    #Copy the fields from the super type
    if stype != nothing !isabstracttype(stype)
        for field in 1:fieldcount(stype)
            push!(structBlock.args, Expr(:(::), Symbol(fieldname(stype, field)), Symbol(fieldtype(stype, field))))
        end
    end

    abstract_name = aclazz_parent_expr.args[aclazz_sym_idx]
    #Pass One To Convert Everything to Abstract and Move everything outside Struct
    search_for_symbols(body, (p, i, r) -> p.args[i] = abstract_name, [clazz])
    for item in body.args
        push!(expr.args, item)
    end


    #Treat abstract extension type as clazz in constructor
    generic_types = deepcopy(aclazz_parent_expr)
    out = search_forany_symbols(generic_types)
    deleteat!(out.parent.args, out.pindex)
    aclazz_parent_expr.args[aclazz_sym_idx] = Symbol(clazz)
    newargs = Expr(:call, :new, generic_types)
    conargs = Expr(:call, aclazz_parent_expr)
    inner_function = conargs


    push!(expr.args, Expr(:function, inner_function, Expr(:block, newargs)))


    #Create Constructors for functions
    search_for_heads(body,
        function(p, i, r)
            if i != 0
                function_args = search_for_heads(r, [:call])
                function_name = function_args.result.args[1]
                if function_name == abstract_name
                    if !has_clazz_super
                        search_for_symbols(r,
                            function(p2, i2, r2)
                                p2.args[i2] = sclazz
                            end, [:super])
                    end
                    #Insert Self into first arg of constructor
                    insert!(function_args.result.args, 2, Expr(:(::), :self, aclazz))
                    #Push constructor that is the interface constructor to the user

                else

                end
            end
        end, [:function])

    println(expr)

    #expr
end

struct TestClass{C1, C2 <: Real}
    f::C1
    f2::C2
end

@print_tree begin
    abstract type AbstractT2{C, C1 <: Real} end
    struct T2{C, C1 <: Real} <: AbstractT2{C, C1}
        function T2{C}(v::T3, v2::T4) where T3 where T4
            new{C}()
        end
        T2() = T1(4)
    end
end


@class T3{C1, C2 <: Real} <: Test{C1, C2} begin
    function T3()
        super("Hi")
    end

    function t(v)
    end
end
