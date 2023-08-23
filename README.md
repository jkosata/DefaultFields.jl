![tests](https://github.com/jkosata/DefaultFields.jl/workflows/tests/badge.svg?branch=master)

This is a simple package to enable declaring fields for abstract types in Julia, see https://github.com/JuliaLang/julia/issues/4935

- allow kwdefs in `@with_fields` (ensure the call of `@with_kw` or `Base.@kwdef` by the newly-created macro)
- check full compatibility with `Parameters.jl`
- check `Base.@kwdef`
- add more input checks
- option to disable abstract types (?)
