module AbstractFields

export @with_fields

# respects mutable / immutable
function add_field(typedef, fields...)
    @assert typedef.head == :struct
    fdef = typedef.args[3]

    dupl = intersect(_fieldnames.(fields), _fieldnames(fdef))
    length(dupl) == 0 || error("syntax: duplicate field name: $(dupl...)")

    push!(fdef.args, fields...)
    typedef
end

macro with_fields(namedef, fields...)

    allunique(_fieldnames.(fields)) || error("syntax: duplicate field name: $(_duplicates(_fieldnames.(fields))...)")
    typename = namedef isa Expr ? error("Abstract types not supported") : namedef
    absdef = Expr(:abstract, namedef)

    macrodef = quote
        macro $(typename)(typedef)
            typedef.args[2] = :($(typedef.args[2]) <: $$namedef)
            $add_field(typedef, $((Meta.quot(f) for f in fields)...))
        end
    end
    esc(:($absdef, $macrodef))
end

""" Return the names of fields defined in `fdef`. """
function _fieldnames(fdef::Expr)
    fdef.head == :block && return Symbol.(filter(!isnothing, (_fieldnames.(fdef.args))))
    fdef.head == :(::) && return fdef.args[1]
    nothing
end

_fieldnames(s::Symbol) = s
_fieldnames(arb) = nothing

""" Return the list of elements in `a` which occur more than once. """
_duplicates(a) = filter( el -> length(findall(==(el), a)) > 1, unique(a) )

end