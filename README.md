## `AVCUtils`

Implemented Utils:
* `ArrayList`: array-based list with push and pop operations to the end of the list. Reserves the necessary space and grows when necessary.
* Strong types: macro `@def_strong_type` defines a thin wrapper over some type `T`. Provides explicit conversion back to `T` via either `convert` or `T()`. Thus, strong types can be used to
  - Assign array elements without explicit conversion
  - Assign local explicitly typed variables
  - Initialize `struct` fields with `new`.
