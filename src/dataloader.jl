using StaticArrays

Pt = SVector{2, Float64}
HomoPt = SVector{3, Float64}
HomoMtx= SMatrix{3, 3, Float64}

struct Measurement
    odom::HomoMtx
    points::Vector{Pt}
end

polar_to_cartesian(r, θ) = Pt([r * cos(θ), r * sin(θ)])

cartesian_to_homogeneous(x, y) = HomoPt([x, y, 1])

odom_tf_mtx(x, y, ϕ) = HomoMtx([cos(ϕ) -sin(ϕ) x; sin(ϕ) cos(ϕ) y; 0 0 1])

function euclidean_points(scan::Vector{Float64})
    points = Pt[]

    # lidar sweeps from -π/2 to π/2 where +x-axis is at 0 rad
    beam_angle_increment = π/180
    beam_angle = -π/2 # measurements start from bottom and sweep up

    nonzero_range(x) = x > 0.05
    for range in filter(nonzero_range, scan)
        push!(points, polar_to_cartesian(range, beam_angle))
        beam_angle += beam_angle_increment
    end

    points
end


function read_data(odom_file_name="data/intel_ODO.txt", scan_file_name="data/intel_LASER.txt")::Vector{Measurement}
    # Intel dataset we are using guarantees temporal alignment of odometry and laser measurements
    measurements = Measurement[]

    # use eachline() instead of readlines() to produce an iterator instead of loading all file contents
    # into memory at once https://stackoverflow.com/questions/58169711/how-to-read-a-file-line-by-line-in-julia
    for (odom_line, scan_line) in zip(eachline(odom_file_name), eachline(scan_file_name))
        odom_x, odom_y, odom_ϕ = parse.(Float64, split(odom_line, " "))
        scan = parse.(Float64, split(scan_line, " "))
        @assert typeof(scan) == Vector{Float64}

        odom_transformation = odom_tf_mtx(odom_x, odom_y, odom_ϕ)
        scan_points = euclidean_points(scan)

        push!(measurements, Measurement(odom_transformation, scan_points))
    end

    return measurements
end