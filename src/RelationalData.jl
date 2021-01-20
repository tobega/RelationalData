module RelationalData
export Heading, apply, Relation

"""
    Heading

A `Heading` defines names and types for a relation.
"""
struct Heading
  names::Tuple{Vararg{Symbol}}
  types::Tuple{Vararg{DataType}}

  function Heading(h::NamedTuple{names, T} where {names, T<:Tuple{Vararg{DataType}}})
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

"""
    apply(h::Heading, nt::NamedTuple)

Asserts that the named tuple conforms to the heading and returns the named tuple with attributes sorted in the canonical order.
"""
function apply(h::Heading, nt::NamedTuple)
  length(nt) == length(h.names) || throw(DomainError(nt, "Does not match $h"))
  ont = NamedTuple{h.names}(nt)
  isa(values(ont), Tuple{h.types...}) || throw(DomainError(nt, "Does not match $h"))
  ont
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
