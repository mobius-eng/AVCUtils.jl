# AVCUitls module - b/c vscode plugin bug
module AVCUtils

include("StrongTypes2.jl")
include("List.jl")

import .StrongTypes: AbstractStrongType, @def_strong_type
import .List: ArrayList

export AbstractStrongType, @def_strong_type, ArrayList

end # module
