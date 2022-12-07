#main run function to test scan
using Infiltrator, Distributed, LinearAlgebra



function _run()
    """
    Run function, initialize graph, dataloader, optimizer, etc... then start plotting map
    """

    DATASET = read_data()
    lasers = Vector{Vector{Pt}}(undef, 0)

    #init _Graph()
    # graph = _Graph() Gotta redo the graph so it works with the frontend data
    graph = initGraph(DATASET)
    prev_odom = Nothing
    prev_idx = Nothing

    for (odx_idx, data) in enumerate(DATASET)
        if odx_idx == 1
            prev_idx = 1
            prev_odom = copy(data.odom)
            B = data.points
            push!(lasers, data.points)
            continue
        end
        delta_x = abs.(mtx_tf_odom(data.odom) - mtx_tf_odom(prev_odom))
        if abs(delta_x[2]) > 0.1 || norm(delta_x[1:2]) > 0.2 || abs(delta_x[1]) > 0.1
            A = lasers[prev_idx]
            B = data.points
            P = Nothing
            tf_mtx = Nothing
            try
                tf_mtx, P, norm = icp_svd(B, A)
            catch e
                println("$e")
                println("error in trying to find icp_svd")
                continue
            end

            B_pose = tf_mtx * data.odom
            vertex_id = graph.numberofvertex + 1
            addVertex(graph, vertex_id, B_pose, B)
            
            prev_idx = vertex_id
            prev_odom = data.odom
            push!(lasers, data.points)

            #test loop closure every 10 vertices added...
            if (graph.numberofvertex >= 2) && vertex_id % 2 == 0
                currentIdx, landmarkIdx, P, matrix_T, closeFlag = test_loop_closer(lasers, vertex_id, B)
                if closeFlag && abs(landmarkIdx - currentIdx) > 1
                    addEdge(graph, landmarkIdx, currentIdx, P, matrix_T) #collects all valid transformations and points
                    println("similar shape: $landmarkIdx , $currentIdx")
                    plot_scans(get_points(graph, currentIdx), get_points(graph, landmarkIdx)) #to test if point maps look similar
                    closeFlag = false
                    # @infiltrate
                end
            end 
            #draw map pose results every # results... 
        end
        
    end

    # graph = loadData(data)
    # fg = constructGraph(graph)
    # solveTree!(fg) #pose graph solver
    # pl = plotSLAM2D(fg, drawhist=true, drawPoints=false) #plots pose graph
end