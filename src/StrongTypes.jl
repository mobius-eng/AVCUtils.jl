# StrongTypes
module StrongTypes

export NamedType, @def_strong_type

struct NamedType{NameType, DataType}
    value::DataType
    NamedType(::Type{NameType}, x::DataType) where {NameType, DataType} =
        new{NameType, DataType}(x)
end

Base.convert(::Type{DataType}, x::NamedType{NameType, DataType}) where {DataType, NameType} =
    x.value

(::Type{T})(x::NamedType{N,T}) where {N,T} = x.value

# Type aliases, on which this implementation relies do not print
# well when imported. See alternative implementation that streamlines
# the implementation
macro def_strong_type(name)
    name_tag = gensym(String(name) * "_tag")
    quote
        abstract type $(esc(name_tag)) end
        const $(esc(name)){T} = NamedType{$(esc(name_tag)), T}
        $(esc(name))(x) = NamedType($(esc(name_tag)), x)
    end
end


end
