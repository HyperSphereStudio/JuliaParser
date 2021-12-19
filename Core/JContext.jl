struct JContext
    version::AbstractJuliaVersion
    stack::Vector{AbstractJuliaObject}

    JContext(version::AbstractJuliaVersion) = new(version, [])

    Base.getindex(context::JContext, i::Int) = context.stack[i]
    Base.setindex(context::JContext, i::Int, v::AbstractJuliaObject) = context.stack[i] = v

end

clear!(context::JContext) = deleteat!(context.stack, 1:length(context))
empty(context::JContext) = length(context) == 0
front(context::JContext) = empty(context) ? nothing : context.stack[1]
last(context::JContext) = empty(context) ? nothing : context.stack[end]

function Base.length(context::JContext)
    return length(context.stack)
end

function Base.push!(context::JContext, obj::AbstractJuliaObject)::AbstractJuliaObject
    push!(context.stack, obj)
    obj
end

function Base.pop!(context::JContext)::AbstractJuliaObject
    last = context.stack[end]
    deleteat!(context.stack, length(context.stack))
    last
end

function parse(expr, context::JContext)
    return context.version.Parser(expr, context)
end
