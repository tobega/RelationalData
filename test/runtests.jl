using Test, RelationalData

@test Heading((a = Int, b = String)) == Heading((b = String, a = Int))

@test Heading((d = 1, e = "foo")) == Heading((e = "bar", d = 2))

@test Heading((a = Int, b = String)) == Heading((b = "bar", a = 2))

@test Heading((c = Int, a = Int, b = String)) == Heading((b = "bar", a = 2, c = 5))

@test apply(Heading((c = Int, a = Int, b = String)), (b = "bar", a = 2, c = 5)) == (a = 2, b = "bar", c = 5)

@test typeof(Relation([(a=1, b="foo", c=3.14)])) == Relation{(:a, :b, :c), Tuple{Int64, String, Float64}}
