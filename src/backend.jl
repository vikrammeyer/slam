""" Construct the pose graph and solve using Caesar
"""

# using Caesar, RoMEPlotting
# using Infiltrator
# using Distributed
# addprocs(8) # note this yields 6*8=40 possible processing threads



# function initCaeserGraph(graph)
#     fg = initfg()
#     # @infiltrate
#     lengthTraj = graph.numberofvertex
#     firstObs = get_pose(graph, 1)
#     addVariable!(fg, :x0, Pose2)
#     addFactor!(fg, [:x0], PriorPose2(MvNormal([firstObs[1], firstObs[2], firstObs[3]], 0.01*Matrix(Diagonal([1;1;1])))))
#     for i in 1:lengthTraj-1
#         addVariable!(fg, Symbol("x",i), Pose2)
#     end
#     for i in 0:(lengthTraj-2)
#         println(i)
#         psym = Symbol("x$i")
#         nsym = Symbol("x$(i + 1)")
#         pose = get_pose(graph, i+2)
#         # addVariable!(fg, nsym, Pose2)
#         # pp = Pose2Pose2(MvNormal([10.0;0; (i % 2 == 0 ? -pi/3 : pi/3)], Matrix(Diagonal([0.1;0.1;0.1].^2))))
#         pp = Pose2Pose2(MvNormal([pose[1], pose[2], pose[3]], 0.0001*Matrix(Diagonal([1;1;1]))))
#         addFactor!(fg, [psym;nsym], pp)
#     end
#     @infiltrate
#     return fg
# end

# function constructGraph(graph)
#     """
#     Wrapper to construct Caesar.jl factor graph from _Graph struct
#     """
#     fg = initfg()
#     lengthTraj = graph.length
#     firstObs = get_pose(graph, 1)
#     addVariable!(fg, :x0, Pose2)
#     addFactor!(fg, [:x0], PriorPose2(MvNormal([firstObs[1], firstObs[2], firstObs[3]], 0.01*Matrix(Diagonal([1;1;1])))))
#     for i in 1:lengthTraj-1
#         addVariable!(fg, Symbol("x",i), Pose2)
#     end
#     for i in 0:(lengthTraj-2)
#         println(i)
#         psym = Symbol("x$i")
#         nsym = Symbol("x$(i + 1)")
#         pose = get_pose(graph, i+2)
#         # addVariable!(fg, nsym, Pose2)
#         pp = Pose2Pose2(MvNormal([10.0;0; (i % 2 == 0 ? -pi/3 : pi/3)], Matrix(Diagonal([0.1;0.1;0.1].^2))))
#         # pp = Pose2Pose2(MvNormal([pose[1], pose[2], pose[3]], 0.0001*Matrix(Diagonal([1;1;1]))))
#         addFactor!(fg, [psym;nsym], pp)
#     end
#     @infiltrate
#     fg
# end

# function loadData(data)
#     vertices = Vertex[]
#     for (idx, datapt) in enumerate(data)
#         vertex = Vertex(idx, datapt.odom)
#         push!(vertices, vertex) 
#     end
#     # graph = _Graph(vertices, length(data))
#     # graph = _Graph(vertices, 100)
#     graph = _Graph(vertices, 10)
#     return graph
# end

# function optimize(graph::_Graph, max_itr)
#     """TODO"""
# end

# function plot(graph::_Graph)
#     """TODO"""
#     plotSLAM2D(graph, drawhist=true, drawPoints=false)
# end

function test_loop_closer(lasers, currentIdx, currentPoints; normThreshold = 3.0) #normThreshold needs to be experimented with
    landmarkIdx = nothing
    tf_mtx = nothing
    P = nothing
    closeFlag = false
    for (idx, points) in enumerate(lasers[1:end-1])
        tf_mtx, P, l2_norm = icp_svd(points, currentPoints)
        # @infiltrate
        if l2_norm < normThreshold
            landmarkIdx = idx
            closeFlag = true
            println("norm l2 $l2_norm of landmarkIdx $landmarkIdx, current $currentIdx")
            break
        end
    end 
    return currentIdx, landmarkIdx, P, tf_mtx, closeFlag
end