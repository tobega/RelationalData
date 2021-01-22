module RelationalData
export Heading, shapeto, Relation

"""
    Heading

A `Heading` defines names and types for a relation.
"""
struct Heading{names, T}
  function Heading{names, T}() where {names, T<:Tuple}
    sorted = (sort([names...])...,)
    h = NamedTuple{names}(fieldtypes(T))
    head = NamedTuple{sorted}(h)
    new{sorted, Tuple{values(head)...}}()
  end

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

struct Relation
  heading::Heading
  body::Set{NamedTuple}

  Relation(heading::Heading) = new(heading, Set{NamedTuple{heading.names, Tuple{heading.types...}}}())
  Relation(heading::Heading, s::AbstractSet{T}) where {T<:NamedTuple} = new(heading, Set(shapeto.(s, Ref(heading))))
  function Relation(s::AbstractSet{NamedTuple{names, T}}) where {names, T}
    heading = Heading((; zip(names, fieldtypes(T))...))
    new(heading, Set(shapeto.(s, Ref(heading))))
  end
end

end # module
