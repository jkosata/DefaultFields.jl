module DefaultFields

using Parameters
export @with_fields

""" Add `fields` to  a type definition. Fields format: `:(fieldname::Type)`. """
function add_field!(typedef, fields...)
    @assert typedef.head == :struct
    fdef = typedef.args[3]

    dupl = intersect(_fieldnames.(fields), _fieldnames(fdef))
    length(dupl) == 0 || error("syntax: duplicate field name: $(dupl...)")

    push!(fdef.args, fields...)
    typedef
end

"""
```julia
@with_fields atypename fields...
```
Macro to define an abstract type `atypename` that automatically adds `fields` to its subtypes.
The subtypes are declared using the macro `@atypename`.

# Examples:

```julia
@with_fields abs_type a::Int b
@abs_type struct mystruct
    c::Float64
end

julia> fieldnames(mystruct)
(:c, :a, :b)

julia> fieldtypes(mystruct)
(Float64, Int64, Any)

julia> mystruct <: abs_type
true


julia> abstract type supertype end
julia> @with_fields abs_type <: supertype field_a field_b
julia> abs_type <: supertype
true
```
"""
macro with_fields(namedef, fields...)
    allunique(_fieldnames.(fields)) || error("syntax: duplicate field name: $(_duplicates(_fieldnames.(fields))...)")
    macroname = namedef isa Expr ? (namedef.head == :<: ? namedef.args[1] : error("Invalid abstract type declaration")) : namedef

    absdef = Expr(:abstract, namedef)
    macrodef = quote
        macro $(macroname)(typedef)
            typedef.args[2] = :($(typedef.args[2]) <: $$macroname)
            total_def = $add_field!(typedef, $fields...)

            if $_has_kwdefs(typedef)
                # evaluate the with_kw function (not macro), interpolating from this module
                esc($Parameters.with_kw(total_def, @__MODULE__))
            else
                esc(total_def)
            end

        end
    end
    esc(:($absdef, $macrodef))
end

""" Return the names of fields defined in `fdef`. """
function _fieldnames(fdef::Expr)
    fdef.head == :block && return Symbol.(filter(!isnothing, (_fieldnames.(fdef.args))))
    fdef.head == :(::) && return fdef.args[1]
    fdef.head == :(=) && return _fieldnames(fdef.args[1])
    nothing
end

_fieldnames(s::Symbol) = s
_fieldnames(arb) = nothing

""" Return the list of elements in array which occur more than once. """
_duplicates(a) = filter( el -> length(findall(==(el), a)) > 1, unique(a) )

_has_kwdefs(typedef::Expr) = any( (f isa Expr && f.head == :(=) for f in typedef.args[3].args) )

end