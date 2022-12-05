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
    xlims!(0, 20)
    ylims!(-10, 10)
end

function viz_scans(data, gif_output_file="laser.gif")
    anim = @animate for i in eachindex(data)
        plot_scan(data[i].points)
    end
    gif(anim, gif_output_file, fps=1)
end
