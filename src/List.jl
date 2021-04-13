# List
module List

export ArrayList, array_list_from_vector

mutable struct ArrayList{T}
    storage::Vector{T}
    last_index::Int64
    ArrayList(::Type{T}, init_capacity::Int64) where T = new{T}(Vector{T}(undef, init_capacity), 0)
end

function array_list_from_vector(v::AbstractVector{T}) where T
    lst = ArrayList(T, length(v))
    for i = 1:length(v)
        lst.storage[i] = v[i]
    end
    lst.last_index = length(v)
    lst
end

function Base.show(io::IO, lst::ArrayList{T}) where T
    print(io, "ArrayList{$(T)}(")
    if lst.last_index == 0
        print(io, ")")
    else
        for i = 1:lst.last_index-1
            print(io, lst.storage[i])
            print(io, ", ")
        end
        print(io, lst.storage[lst.last_index])
        print(io, ")")
    end
end

function Base.collect(lst::ArrayList{T}) where T
    @inbounds return lst.storage[1:lst.last_index]
end

function Base.push!(lst::ArrayList{T}, item::T) where T
    if lst.last_index >= length(lst.storage)
        new_length = convert(Int64, floor(lst.last_index * 1.5))
        resize!(lst.storage, new_length) 
    end
    lst.last_index += 1
    @inbounds lst.storage[lst.last_index] = item
    return lst
end

function Base.push!(lst::ArrayList{T}, items::AbstractVector{T}) where T
    nv = length(items)
    nlst = length(lst.storage)
    nempty = nlst - lst.last_index
    while nempty < nv
        new_length = convert(Int64, ceil(nlst * 1.5))
        resize!(lst.storage, new_length)
        nlst = new_length
        nempty = nlst - lst.last_index
    end
    for i = 1:length(items)
        lst.last_index += 1
        lst.storage[lst.last_index] = items[i]
    end
    lst
end

Base.isempty(lst::ArrayList{T}) where T = lst.last_index < 1

function Base.pop!(lst::ArrayList{T}) where T
    if isempty(lst)
        throw(ArgumentError("list must be non-empty"))
    else
        x = lst.storage[lst.last_index]
        lst.last_index -= 1
        x
    end
end

function Base.getindex(lst::ArrayList{T}, index::Integer) where T
    if index < 1 || index > lst.last_index
        throw(BoundsError(lst, index))
    else
        @inbounds lst.storage[index]
    end
end

function Base.getindex(lst::ArrayList{T}, index::AbstractVector{I}) where {T, I <: Integer}
    n = length(index)
    ilast = last(index)
    ifirst = first(index)
    if n == 0
        ArrayList(T, 1)
    elseif ifirst > lst.last_index || ifirst < 1 || ilast > lst.last_index
        throw(BoundsError(lst, index))
    else
        result = ArrayList(T, n)
        for i = index
            push!(result, lst[i])
        end
        result
    end
end

function Base.getindex(lst::ArrayList{T}, index::AbstractVector{Bool}) where {T}
    n = length(index)
    if n == 0
        ArrayList(T, 1)
    elseif n > lst.last_index
        throw(BoundsError(lst, index))
    else
        newn = min(n, lst.last_index)
        result = ArrayList(T, newn)
        for i = 1:newn
            if (index[i])
                push!(result, lst[i])
            end
        end
        result
    end
end

function Base.setindex!(lst::ArrayList{T}, value::T, index::I) where {T, I <: Integer}
    if index >= 1 && index <= lst.last_index
        lst.storage[index] = value
        nothing
    elseif index == lst.last_index + 1
        lst.last_index += 1
        lst.storage[index] = value
        nothing
    else
        throw(BoundsError(lst, index))
    end
end

function Base.setindex!(lst::ArrayList{T}, value::AbstractVector{T},
                        index::AbstractVector{I}) where {T, I <: Integer}
    n = length(index)
    nv = length(value)
    ilast = last(index)
    ifirst = first(index)
    if n != nv
        throw(DimensionMismatch("tried to assigning $(nv) elements to $(n) destinations"))
    elseif n == 0
        nothing
    elseif ifirst > lst.last_index || ifirst < 1 || ilast > lst.last_index
        throw(BoundsError(lst, index))
    else
        lst.storage[index] = value
        nothing
    end
end

function Base.first(lst::ArrayList{T}) where T
    if lst.last_index < 1
        throw(BoundsError(lst, 1))
    else
        lst.storage[1]
    end
end

function Base.last(lst::ArrayList{T}) where T
    if lst.last_index < 1
        throw(BoundsError(lst, 0))
    else
        lst.storage[lst.last_index]
    end
end

function Base.iterate(lst::ArrayList{T}, state = 1) where T
    if state > lst.last_index
        return nothing
    else
        @inbounds return (lst.storage[state], state + 1)
    end
end

function Base.iterate(lst::Base.Iterators.Reverse{ArrayList{T}}, state = 1) where T
    l = lst.itr
    if state > l.last_index
        return nothing
    else
        @inbounds return (l.storage[l.last_index - state + 1], state + 1)
    end
end


Base.length(lst::ArrayList{T}) where T = lst.last_index


function Base.reverse(lst::ArrayList{T}) where T
    n = length(lst)
    result = ArrayList(T, n)
    for i = n:-1:1
        result.storage[i] = lst.storage[n-i+1]
    end
    result.last_index = n
    result
end

function Base.reverse!(lst::ArrayList{T}) where T
    reverse!((@view lst.storage[1:lst.last_index]))
    lst
end

function Base.filter(f, lst::ArrayList{T}) where T
    # Have no idea what capacity should be
    result = ArrayList(T, length(lst)÷2)
    for x in lst
        if f(x)
            push!(result, x)
        end
    end
    result
end

function Base.filter!(f, lst::ArrayList{T}) where T
    inew = 0
    for i in 1:lst.last_index
        if f(lst.storage[i])
            inew += 1
            if i != inew
                lst.storage[inew] = lst.storage[i]
            end
        end
    end
    lst.last_index = inew
    lst
end

function Base.copy(lst::ArrayList{T}) where T
    result = ArrayList(T, lst.last_index)
    @inbounds for i in 1:lst.last_index
        result.storage[i] = lst.storage[i]
    end
    result.last_index = lst.last_index
    result
end

function Base.sort(lst::ArrayList{T}) where T
    result = ArrayList(T, length(lst))
    result.storage[:] = sort(@view lst.storage[1:lst.last_index])
    result.last_index = lst.last_index
    result
end

function Base.sort!(lst::ArrayList{T}) where T
    sort!(@view lst.storage[1:lst.last_index])
    lst
end

end
