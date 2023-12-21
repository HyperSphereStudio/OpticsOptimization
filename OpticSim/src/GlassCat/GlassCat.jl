# MIT license
# Copyright (c) Microsoft Corporation. All rights reserved.
# See LICENSE in the project root for full license information.

module GlassCat

using Polynomials
using Plots
using StringEncodings
using Unitful
using StaticArrays
using Base: @.
import Unitful: Length, Temperature, Quantity, Units
using Unitful.DefaultSymbols
using Pkg
using ForwardDiff

include("constants.jl")

include("GlassTypes.jl")
export GlassID, info, glassid, glassname, glassforid
include("Air.jl")
export Air, isair

include("data/jl/OTHER.jl")

# include functionality for managing runtime (dynamic) glass cats: MIL_GLASSES and MODEL_GLASSES
include("runtime.jl")
export glassfromMIL, modelglass

# include functions for searching the glass cats
include("search.jl")
export glasscatalogs, glassnames, findglass

include("utilities.jl")
export plot_indices, index, polyfit_indices, absairindex, absorption, drawglassmap

# include utility functions for maintaining the AGF source list
include("sources.jl")
export add_agf

# include build utility scripts to make testing them a bit easier
include("generate.jl")

#Generate Constants
#=
mkpath(AGF_DIR)
mkpath(JL_DIR)

# Build/verify a source directory using information from sources.txt
sources = split.(readlines(SOURCES_PATH))
verify_sources!(sources, AGF_DIR)
verified_source_names = first.(sources)

# Use verified sources to generate required .jl files
@info "Using sources: $(join(verified_source_names, ", ", " and "))"
generate_jls(verified_source_names, AGFGLASSCAT_PATH, JL_DIR, AGF_DIR)
=#

include(raw"data/jl/AGFGlassCat.jl")
end # module
export GlassCat



