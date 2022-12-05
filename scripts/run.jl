#main run function to test scan
# using Revise, SLAM, Plots, Infiltrator
# include("../src/graph.jl")
using Infiltrator, Distributed, LinearAlgebra



function run()
    """
    Run function, initialize graph, dataloader, optimizer, etc... then start plotting map
    """

    DATASET = read_data()[1:100]
    # lasers = []
    lasers = Dict()
    # graph = _Graph() Gotta redo the graph so it works with the frontend data
    prev_odom = Nothing
    prev_idx = Nothing

    for (odx_idx, data) in enumerate(DATASET)
        if odx_idx == 1
            prev_idx = 1
            prev_odom = copy(data.odom)
            B = data.points
            lasers[odx_idx] = B
            continue
        end
        delta_x = abs.(mtx_tf_odom(data.odom) - mtx_tf_odom(prev_odom))
        println("norm btw pts $(norm(delta_x[1:2]))")
        if abs(delta_x[2]) > 0.2 || norm(delta_x[1:2]) > 0.4 || abs(delta_x[1]) > 0.2
            A = lasers[prev_idx]
            B = data.points
            P = Nothing
            tf_mtx = Nothing
            try
                tf_mtx, P = icp_svd(B, A)
            catch e
                println("error in trying to find icp_svd")
                continue
            end

            plot_scans(P, A)
            @infiltrate
            Bpose = tf_mtx * data.odom


            #add vertex and edge ...
            # _Graph.addVertex(Bpose) ... 
            
            
            prev_idx = odx_idx
            prev_odom = data.odom
            lasers[odx_idx] = B

            #test loop closure every 10 vertices added...

            #draw map pose results every # results... 
        
        end
    end


    # graph = loadData(data)
    # fg = constructGraph(graph)
    # solveTree!(fg) #pose graph solver
    # pl = plotSLAM2D(fg, drawhist=true, drawPoints=false) #plots pose graph
end