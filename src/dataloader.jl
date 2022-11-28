polar_to_cartesian(r, θ) = (r * cos(θ), r * sin(θ))

cartesian_to_homogeneous(x, y) = (x, y, 1)

odometry_transform_matrix(x, y, ϕ) = [cos(ϕ) -sin(ϕ) x; sin(ϕ) cos(ϕ) y; 0 0 1]

function ranges_to_homogeneous_points(ranges)
    points = []

    # lidar sweeps from -π/2 to π/2 where +x-axis is at 0 rad
    beam_angle_increment=π/180
    beam_angle = -π/2 # measurements start from bottom and sweep up

    nonzero_range(x) = x > 0.05
    for range in filter(nonzero_range, ranges)
        homo_point = cartesian_to_homogeneous(polar_to_cartesian(range, beam_angle)...)
        push!(points, homo_point)
        beam_angle += beam_angle_increment
    end

    points
end

function read_data(odom_file_name="data/intel_ODO.txt", scan_file_name="data/intel_LASER.txt")
    # Intel dataset we are using guarantees temporal alignment of odometry and laser measurements
    measurements = []

    # use eachline() instead of readlines() to produce an iterator instead of loading all file contents
    # into memory at once https://stackoverflow.com/questions/58169711/how-to-read-a-file-line-by-line-in-julia
    for (odom_line, scan_line) in zip(eachline(odom_file_name), eachline(scan_file_name))
        odom_x, odom_y, odom_ϕ = parse.(Float64, split(odom_line, " "))
        scan_ranges = parse.(Float64, split(scan_line, " "))
        @assert typeof(scan_ranges) == Vector{Float64}

        odom_transformation = odometry_transform_matrix(odom_x, odom_y, odom_ϕ)
        scan_points = ranges_to_homogeneous_points(scan_ranges)

        push!(measurements, (odom_transformation, scan_points))
    end

    return measurements
end