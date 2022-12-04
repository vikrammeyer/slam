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



struct Graph
    edges::Edges
    vertices::Vertex
    chi2::Float64
    gradient::Vector{any}
end 


function addEdges(graph)
    """TODO"""
end

function addVertex(graph, id, pose)
    vertex = Vertex(id, pose)
    push!(graph.vertices, vertex)
end


function get_pose(idx::Int64)
    """TODO"""
end

function cal_chi2(graph::Graph)
    """TODO"""
end

function optimize(graph::Graph, tol. max_itr)
    """TODO"""
end


function plot(graph::Graph)
    """TODO"""
end