# alternative implementation
module StrongTypes

export AbstractStrongType, @def_strong_type

abstract type AbstractStrongType{T} end

Base.convert(::Type{T}, x::U) where {T, U <: AbstractStrongType{T}} = x.value

(::Type{T})(x::U) where {T, U <: AbstractStrongType{T}} = x.value

macro def_strong_type(name, exporting = false)
    quote
        struct $(esc(name)){T} <: AbstractStrongType{T}
            value::T
        end
        $(
            if exporting
                :(export $(esc(name)))
            end
        )
    end
end

# For strong types to work with broadcasting
Base.length(x::SomeStrongType) where {SomeStrongType <: AbstractStrongType} = length(x.value)
Base.iterate(x::SomeStrongType) where {SomeStrongType <: AbstractStrongType} = (x, nothing)
Base.iterate(x::SomeStrongType, ::Nothing) where {SomeStrongType <: AbstractStrongType} = nothing
end
