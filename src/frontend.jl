using LinearAlgebra
""" Implement ICP algorithm using SVD here
    https://www.youtube.com/watch?v=dhzLQfDBx2Q
    https://nbviewer.org/github/niosus/notebooks/blob/master/icp.ipynb
    icp_svd(P, Q, kernel=kernel)
"""

""" Calculate correspondences from P to Q
    using 1-nearest neighbors (∀ pᵢ find closest qⱼ)
"""
function correspondence_idxs(P::Vector{Pt}, Q::Vector{Pt})
    correspondances = Tuple{Int, Int}[]

    for (i, p) in enumerate(P)
        min_dist = Inf
        min_idx = -1
        for (j, q) in enumerate(Q)
            dist = norm(q - p)
            if dist < min_dist
                min_dist = dist
                min_idx = j
            end
        end
        push!(correspondances, (i, min_idx))
    end
    correspondances
end

function center_scan(scan::Vector{Pt}, exclude_idxs::Vector{Int}=Int[])
    avg_x, avg_y = 0.,0.
    n = 0
    for (i, pt) in enumerate(scan)
        if i in exclude_idxs
            continue
        end

        avg_x += pt.x
        avg_y += pt.y
        n += 1
    end
    avg_x /= n
    avg_y /= n

    centered_scan = Pt[]
    for pt in scan
        centered_pt = Pt([pt.x - avg_x, pt.y - avg_y])
        push!(centered_scan, centered_pt)
    end
    (centered_scan, [avg_x, avg_y])
end

function cross_covariance(P, Q, correspondences, kernel= diff -> 1)
    cov = zeros(2,2)
    exclude_idxs = Int[]

    for (i, j) in correspondences
        p = P[i]
        q = Q[j]

        weight = kernel(p - q)
        if weight < 0.01
            push!(exclude_idxs, i)
        end

        cov += weight * q * transpose(p) # weighted outer product
    end

    (cov, exclude_idxs)
end

"""
Find homogeneous transform between two scans
Iteratively apply the SVD decomposition on the cross covariance since
the correspondences are not optimal.

"""
function icp_svd(P, Q, iters=10, kernel= diff -> 1.)
    Q_centered, center_of_Q = center_scan(Q)
    exclude_idxs = Int[]

    for i=1:iters
        P_centered, center_of_P= center_scan(P, exclude_idxs)
        correspondences = correspondence_idxs(P_centered, Q_centered)

        cov, exclude_idxs = cross_covariance(P_centered, Q_centered, correspondences, kernel)

        F = svd(cov)
        R = F.U * F.Vt
        t = center_of_Q - R * center_of_P

        for i in eachindex(P)
            P[i] = R * P[i] + t
        end

        if i == iters
            # TODO: only return a tf if the norm/error is below a certain threshold that
            # indicates a decent scan match was found (or can just return the norm and perform
            # the logic on the slam side)
            tf_mtx = HomoMtx([R t ; 0 0 1])
            return tf_mtx, P
        end
    end
end


""" Simple kernel that ignores points far away (high error)
    TODO: make it a litle less strict (softer scaling)
"""
function kernel(error, threshold=10)
    ret = 0.
    if norm(error) < threshold
        ret = 1.
    end
    ret
end
