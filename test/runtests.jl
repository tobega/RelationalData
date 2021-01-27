using Test, RelationalData

@test RelationalData.Heading().names == ()

@test RelationalData.Heading().t == Tuple{}

@test RelationalData.Heading(()).names == ()

@test RelationalData.Heading(()).t == Tuple{}

@test RelationalData.Heading((a = Int, b = String)) == RelationalData.Heading((b = String, a = Int))

@test RelationalData.Heading((d = 1, e = "foo")) == RelationalData.Heading((e = "bar", d = 2))

@test RelationalData.Heading((a = Int, b = String)) == RelationalData.Heading((b = "bar", a = 2))

@test RelationalData.Heading((c = Int, a = Int, b = String)) == RelationalData.Heading((b = "bar", a = 2, c = 5))

@test RelationalData.shapeto((b = "bar", a = 2, c = 5), RelationalData.Heading((c = Int, a = Int, b = String))) == (a = 2, b = "bar", c = 5)

@test RelationalData.shapeto((a = 2, c = 500), RelationalData.Heading((c = Int, a = Int8))) == (a = Int8(2), c = 500)

@test_throws InexactError RelationalData.shapeto((a = 500, c = 500), RelationalData.Heading((c = Int, a = Int8)))

@test_throws MethodError RelationalData.shapeto((c = 500), RelationalData.Heading((c = Int, a = Int8)))

@test_throws DomainError RelationalData.shapeto((a = 2, b = 50, c = 500), RelationalData.Heading((c = Int, a = Int8)))

@test_throws ErrorException RelationalData.shapeto((b = 500, c = 500), RelationalData.Heading((c = Int, a = Int)))

@test (typeof(Relation((a=Int64, b=String, c=Float64))).parameters...,) == ((:a, :b, :c), Tuple{Int64, String, Float64})

@test (typeof(Relation(Set([(a=1, b="foo", c=3.14)]))).parameters...,) == ((:a, :b, :c), Tuple{Int64, String, Float64})

@test (typeof(Relation(Set([(a=Int8(1), b="foo"), (a=Int8(3), b="foo")]))).parameters...,) == ((:a, :b), Tuple{Int8, String})

@test (typeof(Relation((a=Int8(1), b="foo"), (a=Int8(3), b="foo"))).parameters...,) == ((:a, :b), Tuple{Int8, String})

@test Relation((a=1, b="foo"), (a=3, b="bar")).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation((a=Int64, b=String), (1, "foo"), (3, "bar")).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation((a=Int8, b=String), (1, "foo"), (3, "bar")).body == Set([(a=Int8(1), b="foo"), (a=Int8(3), b="bar")])

@test Relation((b=String, a=Int64), ("foo", 1), ("bar", 3)).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation((a=Int64, b=String), [(1, "foo"), (3, "bar")]).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation((a=Int8, b=String), [(1, "foo"), (3, "bar")]).body == Set([(a=Int8(1), b="foo"), (a=Int8(3), b="bar")])

@test Relation((b=String, a=Int64), [("foo", 1), ("bar", 3)]).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test (typeof(Relation()).parameters...,) == ((), Tuple{})

@test (typeof(Relation(())).parameters...,) == ((), Tuple{})

@test (typeof(Relation([])).parameters...,) == ((), Tuple{})

@test (typeof(Relation([()])).parameters...,) == ((), Tuple{})

@test (typeof(Relation([(a=1, b="foo"), (a=3.14, b="bar"), (b="qux", a=6)])).parameters...,) == ((:a, :b), Tuple{Float64, String})

@test [t.a for t in Relation((a=1, b=2), (a=5, b=9))] == [1,5]

@test filter(t -> t.a < 4, Relation((a=1, b=2), (a=5, b=9))) == Relation((a=1, b=2))

@test Relation((a=Int8, b=Int8)) != Relation((a=Int64, b=Int64))

@test restrict(Relation((a=1, b=2), (a=5, b=9)), t -> t.a < 4) == Relation((a=1, b=2))

@test extend(Relation((a=1, b=2), (a=5, b=9)), :sum, t -> t.a+t.b) == Relation((a=1, b=2, sum=3), (a=5, b=9, sum=14))

@test rename(Relation((a=1, b=2), (a=5, b=9)), :a=>:x) == Relation((x=1, b=2), (x=5, b=9))

@test rename(Relation((a=1, b=2), (a=5, b=9)), :a=>:y, :b=>:x) == Relation((y=1, x=2), (y=5, x=9))

@test project(Relation((a=1, b=2, c="foo"), (a=1, b=3, c="foo"), (a=5, b=9, c="bar")), :a, :c) == Relation((a=1, c="foo"), (a=5, c="bar"))

@test_throws ErrorException project(Relation((a=1, b=2, c="foo"), (a=1, b=3, c="foo"), (a=5, b=9, c="bar")), :a, :z)

@test naturaljoin(Relation((a=1, b=2), (a=5, b=9)), Relation((a=1, c="foo"), (a=1, c="bar"), (a=2, c="foo"))) == Relation((a=1, b=2, c="foo"), (a=1, b=2, c="bar"))

@test naturaljoin(Relation((a=1, b=2)), Relation((c="foo",), (c="bar",))) == Relation((a=1, b=2, c="foo"), (a=1, b=2, c="bar"))

@test union(Relation((c="bar", a=1)), Relation((a=4, c="foo"))) == Relation((a=1, c="bar"), (a=4, c="foo"))

@test union(Relation((c="bar", a=1)), Relation((c="bar", a=1))) == Relation((c="bar", a=1))

@test Relation((c="bar", a=1)) ∪ Relation((a=4, c="foo")) == Relation((a=1, c="bar"), (a=4, c="foo"))

@test union(Relation((c="bar", a=1)), Relation((a=4, c="foo")), Relation((a=4, c="foo"))) == Relation((a=1, c="bar"), (a=4, c="foo"))
