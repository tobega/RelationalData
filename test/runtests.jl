using Test, RelationalData

@test typeof(Heading()) == Heading{(), Tuple{}}

@test typeof(Heading(())) == Heading{(), Tuple{}}

@test Heading((a = Int, b = String)) == Heading((b = String, a = Int))

@test Heading((d = 1, e = "foo")) == Heading((e = "bar", d = 2))

@test Heading((a = Int, b = String)) == Heading((b = "bar", a = 2))

@test Heading((c = Int, a = Int, b = String)) == Heading((b = "bar", a = 2, c = 5))

@test shapeto((b = "bar", a = 2, c = 5), Heading((c = Int, a = Int, b = String))) == (a = 2, b = "bar", c = 5)

@test shapeto((a = 2, c = 500), Heading((c = Int, a = Int8))) == (a = Int8(2), c = 500)

@test_throws InexactError shapeto((a = 500, c = 500), Heading((c = Int, a = Int8)))

@test_throws MethodError shapeto((c = 500), Heading((c = Int, a = Int8)))

@test_throws DomainError shapeto((a = 2, b = 50, c = 500), Heading((c = Int, a = Int8)))

@test_throws ErrorException shapeto((b = 500, c = 500), Heading((c = Int, a = Int)))

@test typeof(Relation(Heading((a=Int64, b=String, c=Float64)))).parameters[1] == Heading((a=Int64, b=String, c=Float64))

@test typeof(Relation(Set([(a=1, b="foo", c=3.14)]))).parameters[1] == Heading((a=Int64, b=String, c=Float64))

@test typeof(Relation(Set([(a=Int8(1), b="foo"), (a=Int8(3), b="foo")]))).parameters[1] == Heading((a=Int8, b=String))

@test typeof(Relation((a=Int8(1), b="foo"), (a=Int8(3), b="foo"))).parameters[1] == Heading((a=Int8, b=String))

@test Relation((a=1, b="foo"), (a=3, b="bar")).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation(Heading((a=Int64, b=String)), (1, "foo"), (3, "bar")).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test Relation(Heading((a=Int64, b=String)), [(1, "foo"), (3, "bar")]).body == Set([(a=1, b="foo"), (a=3, b="bar")])

@test typeof(Relation()).parameters[1] == Heading()

@test typeof(Relation(())).parameters[1] == Heading()

@test typeof(Relation([])).parameters[1] == Heading()

@test typeof(Relation([()])).parameters[1] == Heading()

@test typeof(Relation([(a=1, b="foo"), (a=3.14, b="bar"), (b="qux", a=6)])).parameters[1] == Heading((a=Float64, b=String))

@test [t.a for t in Relation((a=1, b=2), (a=5, b=9))] == [1,5]

@test filter(t -> t.a < 4, Relation((a=1, b=2), (a=5, b=9))) == Relation((a=1, b=2))

@test Relation(Heading((a=Int8, b=Int8))) != Relation(Heading((a=Int64, b=Int64)))

@test restrict(Relation((a=1, b=2), (a=5, b=9)), t -> t.a < 4) == Relation((a=1, b=2))

@test extend(Relation((a=1, b=2), (a=5, b=9)), :sum, t -> t.a+t.b) == Relation((a=1, b=2, sum=3), (a=5, b=9, sum=14))

@test rename(Relation((a=1, b=2), (a=5, b=9)), :a=>:x) == Relation((x=1, b=2), (x=5, b=9))

@test rename(Relation((a=1, b=2), (a=5, b=9)), :a=>:y, :b=>:x) == Relation((y=1, x=2), (y=5, x=9))
