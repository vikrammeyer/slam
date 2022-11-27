# note: implement noise and outliers later if time
# TODO:
# read laser scan data and odometry in sync
# implement ICP scan matching algorithm
#   using ICP w/ SVD is probably the easiest to implement (can add robustness to outliers later if necessary)
#   gives us a transformation between scans we can use for constraint graph
# build graph using constraints from odometry and ICP
# run least squares energy minimization on the pose graph to get the graph update
# display the resulting map at the end of each update step (just plot as img- can turn all imgs into gif for demo)

struct Lidar2D
    range_meters::Real
    scan_angle_radians::Real
    rate::Int
    n_rays::Int
end

struct Obstacle
    x::Real
    y::Real
    radius::Real
end

struct Wall
    x::Real
    y::Real
    width::Real
    height::Real
end

struct Robot
    lidar::Lidar2D
    x::Real
    y::Real
    θ::Real
end

struct Environment
    obstacles::Array{Obstacle}
    walls::Array{Wall}
end


function move!(robot::Robot, x, y, θ)
    robot.x = x
    robot.y = y
    robot.θ = θ
end


function calc_lidar_rays(robot)
    a = robot.lidar.scan_angle_radians / 2

    start_θ = robot.θ - a
    end_θ = robot.θ + a

    n_rays = robot.lidar.n_rays

    collect(range((start_θ, end_θ, length=n_rays)))
end


# get robot displayed in the World
# move robot around using keys (assume side to side driving for simple odometry)
# calculate lidar points in the world (can add noise in later)
# display lidar point cloud over the world