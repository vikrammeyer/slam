using Plots
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
