using Caesar
using Infiltrator
using RoMEPlotting


struct Edge
    vertex_id_1::Int64
    vertex_id_2::Int64
    points::Vector{Pt}
    tf_matrix::SMatrix{3, 3, Float64}
end


struct Vertex
    id::Int64
    pose::Array{Float64, 2}
    points::Vector{Pt}
end



mutable struct _Graph
    vertices::Vector{Vertex}
    length::Int64
    numberofvertex::Int64
    edges::Vector{Edge}
    numberofedges::Int64
end 


function addEdge(graph, startidx, endidx, points, tf_mtx)
    """TODO"""
    edge = Edge(startidx, endidx, points, tf_mtx)
    graph.numberofedges += 1
    push!(graph.edges, edge)
end

function constructGraph(graph)
    """
    Wrapper to construct Caesar.jl factor graph from _Graph struct
    """
    fg = initfg()
    lengthTraj = graph.length
    firstObs = get_pose(graph, 1)
    addVariable!(fg, :x0, Pose2)
    addFactor!(fg, [:x0], PriorPose2(MvNormal([firstObs[1], firstObs[2], firstObs[3]], 0.01*Matrix(Diagonal([1;1;1])))))
    for i in 1:lengthTraj-1
        addVariable!(fg, Symbol("x",i), Pose2)
    end
    for i in 0:(lengthTraj-2)
        println(i)
        psym = Symbol("x$i")
        nsym = Symbol("x$(i + 1)")
        pose = get_pose(graph, i+2)
        # addVariable!(fg, nsym, Pose2)
        pp = Pose2Pose2(MvNormal([10.0;0; (i % 2 == 0 ? -pi/3 : pi/3)], Matrix(Diagonal([0.1;0.1;0.1].^2))))
        # pp = Pose2Pose2(MvNormal([pose[1], pose[2], pose[3]], 0.0001*Matrix(Diagonal([1;1;1]))))
        addFactor!(fg, [psym;nsym], pp)
    end
    @infiltrate
    fg
end

function initGraph(dataset)
    firstObs = dataset[1]
    vertices = Vector{Vertex}(undef, 0)
    edges = Vector{Vertex}(undef, 0)
    vertex = Vertex(1, firstObs.odom, firstObs.points)
    lengthTraj = length(dataset)
    push!(vertices, vertex)
    graph = _Graph(vertices, lengthTraj, 1, edges, 0)
    graph
end

function loadData(data)
    vertices = Vertex[]
    for (idx, datapt) in enumerate(data)
        vertex = Vertex(idx, datapt.odom)
        push!(vertices, vertex) 
    end
    # graph = _Graph(vertices, length(data))
    # graph = _Graph(vertices, 100)
    graph = _Graph(vertices, 10)
    return graph
end

function addVertex(graph, id, pose, points)
    vertex = Vertex(id, pose, points)
    graph.numberofvertex += 1
    push!(graph.vertices, vertex)
end

function get_points(graph::_Graph, idx::Int64)
    return graph.vertices[idx].points
end

function get_pose(graph::_Graph, idx::Int64)
    """TODO"""
    return mtx_tf_odom(graph.vertices[idx].pose)
end


function optimize(graph::_Graph, max_itr)
    """TODO"""
end


function plot(graph::_Graph)
    """TODO"""
    plotSLAM2D(graph, drawhist=true, drawPoints=false)
end