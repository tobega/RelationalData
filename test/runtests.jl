using Test, RelationalData

@test typeof(Relation([(a=1, b="foo", c=3.14)])) == Relation{(:a, :b, :c), Tuple{Int64, String, Float64}}
