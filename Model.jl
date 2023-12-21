module Model
    using StaticArrays, ..OpticSim, Unitful.DefaultSymbols 
    using ..OpticSim: Vis, Geometry, Emitters, GlassCat, Repeat, Air, translation, Transform, Examples
    using .GlassCat: OHARA
    using .Emitters: Origins, Directions, Sources
    using ..GLMakie, ..DataFrames

    include("DERAND1.jl")

    const Examples_N_BK7 = GlassCat.Glass("$(@__MODULE__).Examples_N_BK7", 2, 1.03961212, 0.00600069867, 0.231792344, 0.0200179144, 1.01046945, 103.560653, 0.0, 0.0, NaN, NaN, 0.3, 2.5, 1.86e-6, 1.31e-8, -1.37e-11, 4.34e-7, 6.27e-10, 0.17, 20.0, -0.0009, 2.3, 1.0, 7.1, 1.0, 1, 1.0, [(0.3, 0.05, 25.0), (0.31, 0.25, 25.0), (0.32, 0.52, 25.0), (0.334, 0.78, 25.0), (0.35, 0.92, 25.0), (0.365, 0.971, 25.0), (0.37, 0.977, 25.0), (0.38, 0.983, 25.0), (0.39, 0.989, 25.0), (0.4, 0.992, 25.0), (0.405, 0.993, 25.0), (0.42, 0.993, 25.0), (0.436, 0.992, 25.0), (0.46, 0.993, 25.0), (0.5, 0.994, 25.0), (0.546, 0.996, 25.0), (0.58, 0.995, 25.0), (0.62, 0.994, 25.0), (0.66, 0.994, 25.0), (0.7, 0.996, 25.0), (1.06, 0.997, 25.0), (1.53, 0.98, 25.0), (1.97, 0.84, 25.0), (2.325, 0.56, 25.0), (2.5, 0.36, 25.0)], 1.5168, 2.3, 0.0, 0, 64.17, 0, 2.51, 0.0)

    function make_eyeball()
        
        sys = AxisymmetricOpticalSystem{Float64}(DataFrame(
            SurfaceType = ["Object", "Standard", "Image"],
            Radius = [Inf64, 2, Inf64],
            Parameters = [missing, missing, missing],
            Thickness = [Inf64, .1, missing],
            Material = [Air, OHARA.S_LAM3, Air],
            SemiDiameter = [Inf64, 10, 15.0]))
        

        fig = GLMakie.Figure(resolution = (1000, 1000))
        l = LScene(fig[1, 1], scenekw = (; limits = Rect3f(Vec3f(-100, -100, -100), Vec3f(0.0, 0.0, 0.0))))

        Vis.drawtracerays!(l, sys; test = true, trackallrays = true, colorbynhits = true)

        GLMakie.save("test.png", fig)
    end
   
    function objective(a::AbstractVector{T}, b::AxisymmetricOpticalSystem{T}) where {T}
        system = Optimization.updateoptimizationvariables(b, a)
        source = collimatedemitter(SVector(0.0, 0.0, 5.0), 20; λ = 500nm, numrays = 100)
        
        error = zero(T)
        hits = 0
        for r in source
            traceres = trace(system, r, test = true)
            if traceres !== nothing # ignore rays which miss
                hitpoint = point(traceres)
                if abs(hitpoint[1]) > eps(T) && abs(hitpoint[2]) > eps(T)
                    dist_to_axis = hitpoint[1]^2 + hitpoint[2]^2
                    error += dist_to_axis
                end
                hits += 1
            end
        end

        if hits > 0
            error = sqrt(error / hits)
        end
        # if hits == 0 returns 0 - not ideal!
        return error
    end

    function optimize_kernel()

    end

    function optimize()
       
        start, lower, upper = Optimization.optimizationvariables(system)

        optimobjective = arg -> objective(arg, system)
        
    end


end