using Plots

function plot_scans(P, Q)
    pxs = Float64[]
    pys = Float64[]
    for pt in P
        push!(pxs, pt.x)
        push!(pys, pt.y)
    end
    qxs = Float64[]
    qys = Float64[]
    for pt in Q
        push!(qxs, pt.x)
        push!(qys, pt.y)
    end
    
    scatter(pxs, pys, label="P- moved")
    scatter!(qxs, qys, label="Q- true")

end

function plot_scan(scan)
    xs = Float64[]
    ys = Float64[]

    for pt in scan
        push!(xs, pt.x)
        push!(ys, pt.y)
    end

    scatter(xs, ys, ms=2, mc=:blue, legend=false)
    xlims!(-60, 60)
    ylims!(-60, 60)
end


function plot_scan_points_features(odoms, points, features)
    xs = Float64[]
    ys = Float64[]
    for pt in odoms
        push!(xs, pt.x)
        push!(ys, pt.y)
    end
    pointsx = Float64[]
    pointsy = Float64[]
    for point_vec in points
        for pt in point_vec
            push!(pointsx, pt.x)
            push!(pointsy, pt.y)
        end
    end
    featuresx = Float64[]
    fearuresy = Float64[]
    for feature_vec in features
        for pt in feature_vec
            push!(featuresx, pt.x)
            push!(fearuresy, pt.y)
        end
    end
    scatter(xs, ys, ms=1, mc=:red, legend=false)
    scatter!(pointsx, pointsy, ms=0.5, mc=:black)
    scatter!(featuresx, fearuresy, ms=0.6, mc=:green)
    xlims!(-15, 15)
    ylims!(-15, 15)
end

function plot_scan_points(odoms, points, featureFlag)
    xs = Float64[]
    ys = Float64[]

    
    for pt in odoms
        push!(xs, pt.x)
        push!(ys, pt.y)
    end

    pointsx = Float64[]
    pointsy = Float64[]
    for point_vec in points
        for pt in point_vec
            push!(pointsx, pt.x)
            push!(pointsy, pt.y)
        end
    end
    xlims!(-20, 20)
    ylims!(-20, 20)
    scatter(xs, ys, ms=1, mc=:red, legend=false)
    if featureFlag
        xlims!(-20, 20)
        ylims!(-20, 20)
        display(scatter!(pointsx, pointsy, ms=0.8, mc=:green))
        sleep(0.5)
    else
        xlims!(-20, 20)
        ylims!(-20, 20)
        display(scatter!(pointsx, pointsy, ms=0.5, mc=:black))
    end
end

function viz_scans(data, gif_output_file="laser.gif")
    anim = @animate for i in eachindex(data)
        plot_scan(data[i].points)
    end
    gif(anim, gif_output_file, fps=1)
end


function multiPlot(graph)
    xs = Float64[]
    ys = Float64[]
    for vertex in graph.vertices
        for pt in vertex.points
            push!(xs, pt.x)
            push!(ys, pt.y)
        end
    end
    scatter(xs, ys, ms=2, mc=:blue, legend=false)
    xlims!(0, 20)
    ylims!(-10, 10)
end


function plotTwoPoints(A, B)
    x1, y1, θ1 = mtx_tf_odom(A)
    x2, y2, θ2 = mtx_tf_odom(A)
    scatter([x1, y1], [x2, y2])
end