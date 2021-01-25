module RelationalData
export Heading, shapeto, Relation, TABLE_DUM, TABLE_DEE, restrict, extend, rename, project, naturaljoin

"""
    Heading

A `Heading` defines names and types for a relation.
"""
struct Heading{names, T}
  Heading() = new{(), Tuple{}}()
  Heading(empty::Tuple{}) = new{(), Tuple{}}()

  function Heading(h::NamedTuple{names, T} where {names, T<:Tuple{Vararg{DataType}}})
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new{sorted, Tuple{values(head)...}}()
  end

  function Heading(h::NamedTuple)
    sorted = (sort([keys(h)...])...,)
    head = NamedTuple{sorted}(h)
    new{sorted, Tuple{typeof(head).types...}}()
  end
end

"""
    shapeto(nt::NamedTuple, h::Heading)

Returns the named tuple converted to conform to the heading with attributes sorted in the canonical order
and types converted as appropriate (only safe conversions). Throws if conversion is impossible.
"""
function shapeto(nt::NamedTuple, h::Heading)
  head = typeof(h)
  names = head.parameters[1]
  length(nt) == length(names) || throw(DomainError(nt, "Does not match $h"))
  # For some reason we can't get the order right for the types here
  ont = NamedTuple{names}(nt)
  convert(NamedTuple{names, head.parameters[2]}, ont)
end

"""
    Relation

A Relation is a set of named tuples conforming to a Heading
"""
struct Relation{heading}
  body::Set{NamedTuple}

  Relation(heading::Heading) = new{heading}(Set{NamedTuple{typeof(heading).parameters...}}())
  Relation(heading::Heading, s::AbstractSet{T}) where {T<:NamedTuple} = new{heading}(Set(shapeto.(s, Ref(heading))))
  function Relation(s::AbstractSet{NamedTuple{names, T}}) where {names, T}
    heading = Heading((; zip(names, fieldtypes(T))...))
    new{heading}(Set(shapeto.(s, Ref(heading))))
  end
  function Relation(nts::NamedTuple{names, T}...) where {names, T}
    heading = Heading((; zip(names, fieldtypes(T))...))
    new{heading}(Set(shapeto.(nts, Ref(heading))))
  end
  Relation(heading::Heading{names, T}, values::T...) where {names, T} = new{heading}(Set(NamedTuple{names, T}.(values)))
  Relation(heading::Heading{names, T}, itr) where {names, T} = new{heading}(Set(NamedTuple{names, T}.(itr)))
  Relation() = new{Heading()}()
  Relation(empty::Tuple{}...) = new{Heading()}(Set(NamedTuple{(), Tuple{}}(empty[1])))
end

function _promote(h::Heading, nt::NamedTuple)
  head = typeof(h)
  names = head.parameters[1]
  length(nt) == length(names) || throw(DomainError(nt, "Does not match $h"))
  # For some reason we can't get the order right for the types here
  ont = NamedTuple{names}(nt)
  htypes = promote_type.(fieldtypes(head.parameters[2]), fieldtypes(typeof(ont).parameters[2]))
  Heading(convert(NamedTuple{names, Tuple{htypes...}}, ont))
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
  Relation(heading, NamedTuple{typeof(heading).parameters[1]}.(itr))
end

const TABLE_DUM = Relation()
const TABLE_DEE = Relation(())

Base.iterate(r::Relation, i...) = iterate(r.body, i...)
Base.IteratorSize(r::Relation) = Base.HasLength()
Base.length(r::Relation) = length(r.body)
Base.IteratorEltype(r::Relation) = Base.HasEltype()
Base.eltype(r::Relation{heading}) where {heading} = NamedTuple{typeof(heading).parameters...}

Base.:(==)(q::Relation{h}, r::Relation{h}) where {h} = q.body == r.body
Base.:(==)(q::Relation{qh}, r::Relation{rh}) where {qh, rh} = false

Base.filter(f, r::Relation) = Relation(filter(f, r.body))
restrict(r::Relation, f) = filter(f, r)

"""
    extend(r::Relation, s::Symbol, f)

Extends every tuple of a relation with the given symbol assigned the value obtained by applying function f to the tuple.
"""
extend(r::Relation, s::Symbol, f) = Relation([merge(t, (; s => f(t))) for t in r])

function rename(r::Relation{heading}, p::Pair{Symbol,Symbol}...) where {heading}
  replacements = Dict(p...)
  renamed = map(n -> get(replacements, n, n), typeof(heading).parameters[1])
  Relation(Set([NamedTuple{renamed, typeof(heading).parameters[2]}(values(nt)) for nt in r]))
end

project(r::Relation, names::Symbol...) = Relation(Set(NamedTuple{(names...,)}.(r)))

function naturaljoin(r1::Relation{h1}, r2::Relation{h2}) where {h1, h2}
  common = (intersect(typeof(h1).parameters[1], typeof(h2).parameters[1])...,)
  Relation(Set([merge(nt1, nt2) for nt1 in r1 for nt2 in r2 if NamedTuple{common}(nt1) == NamedTuple{common}(nt2)]))
end

end # module
