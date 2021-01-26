module RelationalData
export Heading, shapeto, Relation, TABLE_DUM, TABLE_DEE, restrict, extend, rename, project, naturaljoin

"""
    Heading

A `Heading` defines names and types for a relation.
"""
struct Heading
  names
  t

  Heading() = new((), Tuple{})
  Heading(empty::Tuple{}) = new((), Tuple{})

  function Heading(h::NamedTuple{names, T} where {names, T<:Tuple{Vararg{DataType}}})
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new(sorted, Tuple{values(head)...})
  end

  function Heading(h::NamedTuple)
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new(sorted, Tuple{typeof(head).types...})
  end

  Heading(h::Heading, types::DataType...) = new(h.names, Tuple{types...})
end

"""
    shapeto(nt::NamedTuple, h::Heading)

Returns the named tuple converted to conform to the heading with attributes sorted in the canonical order
and types converted as appropriate (only safe conversions). Throws if conversion is impossible.
"""
function shapeto(nt::NamedTuple, h::Heading)
  length(nt) == length(h.names) || throw(DomainError(nt, "Does not match $h"))
  # For some reason we can't get the order right for the types here
  ont = NamedTuple{h.names}(nt)
  convert(NamedTuple{h.names, h.t}, ont)
end

"""
    Relation

A Relation is a set of named tuples conforming to a Heading
"""
struct Relation{names, T}
  body::Set{NamedTuple}

  Relation(heading::Heading) = new{heading.names, heading.t}(Set{NamedTuple{heading.names, heading.t}}())
  Relation(heading::Heading, s::AbstractSet{T}) where {T<:NamedTuple} = new{heading.names, heading.t}(Set(shapeto.(s, Ref(heading))))
  function Relation(s::AbstractSet{NamedTuple{names, T}}) where {names, T}
    heading = Heading((; zip(names, fieldtypes(T))...))
    new{heading.names, heading.t}(Set(shapeto.(s, Ref(heading))))
  end
  function Relation(nts::NamedTuple{names, T}...) where {names, T}
    heading = Heading((; zip(names, fieldtypes(T))...))
    new{heading.names, heading.t}(Set(shapeto.(nts, Ref(heading))))
  end
  Relation(heading::Heading, values::T...) where {T} = new{heading.names, heading.t}(Set(NamedTuple{heading.names, heading.t}.(values)))
  Relation(heading::Heading, itr) = new{heading.names, heading.t}(Set(NamedTuple{heading.names, heading.t}.(itr)))
  Relation() = new{(), Tuple{}}()
  Relation(empty::Tuple{}...) = new{(), Tuple{}}(Set(NamedTuple{(), Tuple{}}(empty[1])))
end

function _promote(h::Heading, nt::NamedTuple)
  length(nt) == length(h.names) || throw(DomainError(nt, "Does not match $h"))
  # For some reason we can't get the order right for the types here
  ont = NamedTuple{h.names}(nt)
  htypes = promote_type.(fieldtypes(h.t), fieldtypes(typeof(ont).parameters[2]))
  Heading(h, htypes...)
end

function Relation(itr)
  next = iterate(itr)
  if next === nothing
    return Relation()
  end
  heading = Heading(next[1])
  next = iterate(itr, next[2])
  while next !== nothing
    (nt, state) = next
    heading = _promote(heading, nt)
    next = iterate(itr, state)
  end
  Relation(heading, NamedTuple{heading.names}.(itr))
end

const TABLE_DUM = Relation()
const TABLE_DEE = Relation(())

Base.iterate(r::Relation, i...) = iterate(r.body, i...)
Base.IteratorSize(r::Relation) = Base.HasLength()
Base.length(r::Relation) = length(r.body)
Base.IteratorEltype(r::Relation) = Base.HasEltype()
Base.eltype(r::Relation{names, T}) where {names, T} = NamedTuple{names, T}

Base.:(==)(q::Relation{names, T}, r::Relation{names, T}) where {names, T} = q.body == r.body
Base.:(==)(q::Relation{qnames, Q}, r::Relation{rnames, R}) where {qnames, Q, rnames, R} = false

Base.filter(f, r::Relation) = Relation(filter(f, r.body))
restrict(r::Relation, f) = filter(f, r)

"""
    extend(r::Relation, s::Symbol, f)

Extends every tuple of a relation with the given symbol assigned the value obtained by applying function f to the tuple.
"""
extend(r::Relation, s::Symbol, f) = Relation([merge(t, (; s => f(t))) for t in r])

function rename(r::Relation{names, T}, p::Pair{Symbol,Symbol}...) where {names, T}
  replacements = Dict(p...)
  renamed = map(n -> get(replacements, n, n), names)
  Relation(Set([NamedTuple{renamed, T}(values(nt)) for nt in r]))
end

project(r::Relation, names::Symbol...) = Relation(Set(NamedTuple{(names...,)}.(r)))

function naturaljoin(r1::Relation{names1, T1}, r2::Relation{names2, T2}) where {names1, T1, names2, T2}
  common = (intersect(names1, names2)...,)
  Relation(Set([merge(nt1, nt2) for nt1 in r1 for nt2 in r2 if NamedTuple{common}(nt1) == NamedTuple{common}(nt2)]))
end

end # module
