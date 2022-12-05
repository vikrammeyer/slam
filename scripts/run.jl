#main run function to test scan
# using Revise, SLAM, Plots, Infiltrator
# include("../src/graph.jl")
using Infiltrator, Distributed



function run()
    """
    Run function, initialize graph, dataloader, optimizer, etc... then start plotting map
    """
    addprocs(8)
    data = read_data()[1:100]
    graph = loadData(data)
    fg = constructGraph(graph)
    solveTree!(fg) #pose graph solver
    pl = plotSLAM2D(fg, drawhist=true, drawPoints=false) #plots pose graph
end