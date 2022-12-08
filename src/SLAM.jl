module SLAM

include("dataloader.jl")
export read_data, HomoMtx, HomoPt, Pt, mtx_tf_odom, odom_tf_mtx, cartesian_to_homogeneous, polar_to_cartesian
include("viz.jl")
export plot_scan, viz_scans, plot_scan_points_features, plot_scan_points, multiPlot, plotTwoPoints
include("frontend.jl")
export correspondence_idxs, center_scan, cross_covariance, icp_svd, kernel, tf_points
include("graph.jl")
export initGraph, addEdge, addVertex, get_points, get_pose
include("backend.jl")
export test_loop_closer
include("../scripts/run.jl")
export _run


end # module SLAM
