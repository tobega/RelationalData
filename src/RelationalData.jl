module RelationalData
export Heading, shapeto, Relation, TABLE_DUM, TABLE_DEE

"""
    Heading

A `Heading` defines names and types for a relation.
"""
struct Heading{names, T}
  Heading() = new{(), Tuple{}}()

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
  Relation(empty::Tuple{}...) = new{Heading()}(empty[1])
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

end # module
