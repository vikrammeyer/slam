using Caesar
using Infiltrator
using RoMEPlotting


struct Edge
    vertex_ids::Vector{Int64}
    information::Vector{any}
    estimate::Array{Float64, 2}
    vertices::Array{Float64, 2}
end

function calc_error(edge::Edge)
    """TODO"""
end

function calc_chi2(edge::Edge)
    """TODO"""
end

function calc_chi2_gradient(edge::Edge)
    """TODO""" 
end

function calc_jac(edge::Edge)
    """TODO"""
end

function calc_error(edge::Edge)
    """TODO""" 
end



struct Vertex
    id::Int64
    pose::Array{Float64, 2}
end



mutable struct _Graph
    # edges::Edge
    vertices::Vector{Vertex}
    length::Int64
    # chi2::Float64
    # gradient::Vector{any}
end 


function addEdges(graph)
    """TODO"""
end

function constructGraph(graph)
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
        # pp = Pose2Pose2(MvNormal([10.0;0; (i % 2 == 0 ? -pi/3 : pi/3)], Matrix(Diagonal([0.1;0.1;0.1].^2))))
        pp = Pose2Pose2(MvNormal([pose[1], pose[2], pose[3]], 0.0001*Matrix(Diagonal([1;1;1]))))
        addFactor!(fg, [psym;nsym], pp)
    end
    fg
end

function loadData(data)
    vertices = Vertex[]
    for (idx, datapt) in enumerate(data)
        vertex = Vertex(idx, datapt.odom)
        push!(vertices, vertex) 
    end
    # graph = _Graph(vertices, length(data))
    graph = _Graph(vertices, 100)
    return graph
end

function addVertex(graph, id, pose)
    vertex = Vertex(id, pose)
    push!(graph.vertices, vertex)
end


function get_pose(graph::_Graph, idx::Int64)
    """TODO"""
    return mtx_tf_odom(graph.vertices[idx].pose)
end

function cal_chi2(graph::_Graph)
    """TODO"""
end

function optimize(graph::_Graph, max_itr)
    """TODO"""
end


function plot(graph::_Graph)
    """TODO"""
    plotSLAM2D(graph, drawhist=true, drawPoints=false)
end