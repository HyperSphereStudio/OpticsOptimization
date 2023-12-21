using .JuliaSAILGUI, .Observables, .GLMakie, .Gtk4

if !@isdefined OpticSim
    using Pkg
    Pkg.activate("OpticsEnv")

    using Revise
    include(raw"OpticSim/src/OpticSim.jl")
end

include("Model.jl")
using .Model
Model.make_eyeball()

function create_control_panel(gui)
    control_box = GtkGrid(column_homogeneous=true)

    return control_box
end

function create_gui()
    gui = Dict{Symbol, Any}()

	presEntry = GtkEntry()
	conditionDropDown = GtkComboBoxText()
	append!(conditionDropDown, ["Far Sighted", "Near Sighted"])

    win = GtkWindow("Prescription Contact Lens Designer")
    gui[:Window] = win

    grid = GtkGrid(column_homogeneous=true)
	grid[1, 1] = makewidgetwithtitle(presEntry, "Prescription")
	grid[1, 2] = makewidgetwithtitle(conditionDropDown, "Condition")

    TestModule.make_eyeball()
	
    win[] = grid

    return gui
end


function gui_main()
    gui = create_gui()

    #signal_connect(_ -> exit(0), gui[:Window], :close_request)
    
    display_gui(gui[:Window])
    Gtk4.focus(gui[:Window])
    return nothing
end


#gui_main()