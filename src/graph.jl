using Infiltrator

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
    global_tf_matrix::SMatrix{3, 3, Float64}
end

mutable struct _Graph
    vertices::Vector{Vertex}
    length::Int64
    numberofvertex::Int64
    edges::Vector{Edge}
    numberofedges::Int64
end 

function initGraph(dataset)
    firstObs = dataset[1]
    vertices = Vector{Vertex}(undef, 0)
    edges = Vector{Vertex}(undef, 0)
    vertex = Vertex(1, firstObs.odom, firstObs.points, odom_tf_mtx(0, 0, 0))
    lengthTraj = length(dataset)
    push!(vertices, vertex)
    graph = _Graph(vertices, lengthTraj, 1, edges, 0)
    graph
end

function addEdge(graph, startidx, endidx, points, tf_mtx)
    """TODO"""
    edge = Edge(startidx, endidx, points, tf_mtx)
    graph.numberofedges += 1
    push!(graph.edges, edge)
end


function addVertex(graph, id, pose, points, global_tfm)
    vertex = Vertex(id, pose, points, global_tfm)
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
