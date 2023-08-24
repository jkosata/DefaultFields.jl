![tests](https://github.com/jkosata/DefaultFields.jl/workflows/tests/badge.svg?branch=master)

### DefaultFields.jl

This is a simple package to declare abstract types with default fields and their values in Julia. The idea of having this as base functionality is [somewhat disputed](https://github.com/JuliaLang/julia/issues/4935) in the Julia community. I just find it handy sometimes to have a family of types without copypasting blocks of field declarations around.

The macro `@with_fields` defines an abstract type and its default fields.
It then creates another macro to declare subtypes of this abstract type. The default fields are appended to type-particular field definitions.

```julia
julia> using DefaultFields

julia> @with_fields abs_type a_def::Int b_def

julia> @abs_type struct mystruct
            c::Float64
        end

julia> fieldnames(mystruct)
(:c, :a_def, :b_def)

julia> mystruct(1, 2, [])
mystruct(1.0, 2, Any[])

julia> mystruct <: abs_type
true
```

### Default values

Default field values can be entered in both the abstract and concrete declarations (see [`Parameters.jl`](https://github.com/mauro3/Parameters.jl) for syntax). With
```julia
julia> @with_fields abs_type a_def::Int=5 b_def
```
calling
```julia
julia> @abs_type struct mystruct
            c::Float64=6.0
        end
```
Is equivalent to

```julia
using Parameters
abstract type abs_type end
@with_kw struct mystruct <: abs_type
    c::Float64 = 6.0
    a_def::Int = 5
    b_def
end
```

### Supertyping

```julia
julia> abstract type supertype end
julia> @with_fields abs_type <: supertype a_def b_def
julia> abs_type <: supertype
true
```
