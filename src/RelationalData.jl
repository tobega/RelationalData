module RelationalData
export Relation

struct Relation{names, T}
  body::AbstractSet{NamedTuple{names, T}}

  Relation{names, T}() where {names, T} = new(Set{NamedTuple{names, T}}())
  Relation{names, T}(s::AbstractSet{NamedTuple{names, T}}) where {names, T} = new(s)
  Relation(s::AbstractSet{NamedTuple{names, T}}) where {names, T} = new{names, T}(s)
end

Relation(itr) = _Relation(itr, Base.IteratorEltype(itr))

_Relation(itr, ::Base.HasEltype) = Relation(Set{eltype(itr)}(itr))

Base.iterate(r::Relation) = iterate(r.body)
Base.iterate(r::Relation, state) = iterate(r.body, state)
Base.length(r::Relation) = length(r.body)
Base.eltype(::Type{Relation{names, T}}) where {names, T} = NamedTuple{names, T}

end # module
