using Test, RelationalData

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

@test typeof(Relation([(a=1, b="foo", c=3.14)])) == Relation{(:a, :b, :c), Tuple{Int64, String, Float64}}
