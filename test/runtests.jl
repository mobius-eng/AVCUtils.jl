using Test
import AVCUtils

AU = AVCUtils

@testset "ArrayList creation" begin
    lst = AU.ArrayList(Int64, 10)
    @test length(lst) == 0
    @test_throws BoundsError lst[1]
    @test_throws BoundsError lst[2] = 3
end

@testset "ArrayList push! & pop!" begin
    lst = AU.ArrayList(Int64, 4)
    push!(lst, -1)
    @test length(lst) == 1
    @test lst[1] == -1
    @test first(lst) == -1
    @test last(lst) == -1
    lst[2] = -2
    @test length(lst) == 2
    @test first(lst) == -1
    @test last(lst) == -2
    @test lst[2] == -2
    push!(lst, [-3, -4, -5, -6])
    @test length(lst) == 6
    @test lst[3] == -3 && lst[4] == -4 && lst[5] == -5 && lst[6] == -6
    x = pop!(lst)
    @test x == -6
    @test length(lst) == 5
    @test last(lst) == -5
end

@testset "ArrayList list functions" begin
    lst = AU.ArrayList(Float64, 200)
    push!(lst, rand(Float64, 100))
    sorted = sort(lst)
    @test length(sorted) == 100
    @test issorted(sorted)
    @test !issorted(lst)
    sort!(lst)
    @test issorted(lst)
    lst = AU.ArrayList(Int64, 20)
    push!(lst, 1:10)
    rev = reverse(lst)
    vrev = collect(rev)
    @test length(rev) == 10
    @test first(rev) == 10
    @test last(rev) == 1
    @test vrev == collect(10:-1:1)
    reverse!(lst)
    vrev2 = collect(lst)
    @test vrev == vrev2
    lst = AU.ArrayList(Int64, 20)
    push!(lst, 1:10)
    filtered = filter(iseven, lst)
    @test length(filtered) == 5
    @test collect(filtered) == collect(2:2:10)
    filter!(iseven, lst)
    @test collect(lst) == collect(2:2:10)
    lst = AU.ArrayList(Int64, 20)
    push!(lst, 1:10)
    lst2 = copy(lst)
    @test length(lst2) == 10
    @test collect(lst2) == collect(lst)
end

AU.@def_strong_type Height
AU.@def_strong_type Radius

struct Cone{T}
    height::T
    radius::T
    Cone(h::Height{T}, r::Radius{T}) where T = new{T}(h, r)
end

@testset "StrongTypes" begin
    c = Cone(Height(1.0), Radius(2.0))
    @test typeof(c.height) == Float64
    @test_throws MethodError Cone(1.0, 2.0)
    @test Float64(Height(1.0)) == 1.0
    @test convert(Float64, Radius(1.0)) == 1.0
end
