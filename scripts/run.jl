#main run function to test scan
using Infiltrator, Distributed, LinearAlgebra
addprocs(8) # note this yields 6*8=40 possible processing threads




function _run()
    """
    Run function, initialize graph, dataloader, optimizer, etc... then start plotting map
    """

    DATASET = read_data()[1:1000]
    lasers = Vector{Vector{Pt}}(undef, 0)
    global_pos = cartesian_to_homogeneous(0, 0)
    global_tfm = odom_tf_mtx(0, 0, 0)
    global_pos_vec = Vector{SVector{3, Float64}}(undef, 0)
    global_point_vec = Vector{Vector{Pt}}(undef, 0)
    global_features_vec = Vector{Vector{Pt}}(undef, 0)
   
    graph = initGraph(DATASET)
    prev_odom = Nothing
    prev_idx = Nothing
    featureFlag = false

    for (odx_idx, data) in enumerate(DATASET)
        if odx_idx == 1
            prev_idx = 1
            prev_odom = copy(data.odom)
            B = data.points
            push!(lasers, data.points)
            continue
        end
        global_tfm = global_tfm * data.odom
        global_pos = mtx_tf_odom(global_tfm)
        push!(global_pos_vec, global_pos)
        # println("global_pos $global_pos")
        delta_x = abs.(mtx_tf_odom(data.odom) - mtx_tf_odom(prev_odom))
        # if abs(delta_x[2]) > 0.1 || norm(delta_x[1:2]) > 0.2 || abs(delta_x[1]) > 0.1
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

        B_pose = global_tfm * data.odom
        B_point = tf_points(B, global_tfm)
        push!(global_point_vec, B_point)
        vertex_id = graph.numberofvertex + 1
        addVertex(graph, vertex_id, B_pose, B_point, global_tfm)
        
        prev_idx = vertex_id
        prev_odom = data.odom
        push!(lasers, data.points)
        
    
        #test loop closure every 2 vertices added...
        if (graph.numberofvertex >= 10) && vertex_id % 10 == 0
            currentIdx, landmarkIdx, P, matrix_T, closeFlag = test_loop_closer(lasers, vertex_id, B)
            if closeFlag && abs(landmarkIdx - currentIdx) > 1
                addEdge(graph, landmarkIdx, currentIdx, P, matrix_T) #collects all valid transformations and points
                featureFlag = true
                println("similar features: $landmarkIdx , $currentIdx")
                push!(global_features_vec, graph.vertices[landmarkIdx].points)
                push!(global_features_vec, graph.vertices[currentIdx].points)
                # plot_scans(get_points(graph, currentIdx), get_points(graph, landmarkIdx)) #to test if point maps look similar
                closeFlag = false
            end
            
        end 
        plot_scan_points(global_pos_vec, [B_point], featureFlag)
        featureFlag = false
    end
    #create Caesar graph
    # initCaeserGraph(graph)
end