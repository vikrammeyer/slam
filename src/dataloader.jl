
function polar_to_cartesian(θ, r)
    x = r * cos(θ)
    y = r * sin(θ)
    return (x,y)
end

function cartesian_to_homogenous(x, y)
    return (x, y, 1)
end

function odometry_transform_matrix(x, y, ϕ)
    [cos(ϕ), -sin(ϕ), x;
     sin(ϕ), cos(ϕ), y;
     0, 0, 1]
end

function ranges_to_homo_points(ranges, )
    points = Vector{}

    # lidar sweeps from -π/2 to π/2 where +x-axis is at 0 rad
    beam_angle_increment=π/180
    beam_angle = -π/2 # measurements start from bottom and sweep up

    nonzero_range(x) = x > 0.05
    for range in filter(nonzero_range, ranges)
        homo_point = cartesian_to_homogenous(polar_to_cartesian(range, beam_angle)...)
        push!(points, homo_point)
        beam_angle += beam_angle_increment
    end
end

struct Measurement
    # Use homogenous coordinates
    odom::Matrix
    points::Vector{Vector}
end

function read_data(odom_file_name, scan_file_name)
    # Intel dataset we are using guarantees temporal alignment of odometry and laser measurements
    measurements = Vector{Measurement}

    # use eachline() instead of readlines() to produce an iterator instead of loading all file contents
    # into memory at once https://stackoverflow.com/questions/58169711/how-to-read-a-file-line-by-line-in-julia
    for (odom_line, scan_line) in zip(eachline(odom_file_name), eachline(scan_file_name))
        odom_x, odom_y, odom_ϕ = parse.(Float64, split(odom_line, " "))
        scan_ranges = parse.(Float64, split(scan_line, " "))
        @assert typeof(scan_ranges) == Vector{Float64}

        odom_transformation = odometry_transform_matrix(odom_x, odom_y, odom_ϕ)
        scan_points =  ranges_to_points(scan_ranges)

        push!(measurements, Measurement(odom_transformation, scan_points))
    end

    return measurements
end