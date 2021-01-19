module RelationalData
export Heading, Relation

struct Heading
  names::Tuple{Symbol, N} where N
  types::Tuple{DataType, N} where N

  function Heading(h::NamedTuple{names, Tuple{DataType, N}} where {names, N})
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new(sorted, values(head))
  end

  function Heading(h::NamedTuple)
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new(sorted, (typeof(head).types...,))
  end
end

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
