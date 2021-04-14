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

end
