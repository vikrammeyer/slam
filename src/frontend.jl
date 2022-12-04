using LinearAlgebra
""" Implement ICP algorithm using SVD here
    https://nbviewer.org/github/niosus/notebooks/blob/master/icp.ipynb
"""

""" Calculate correspondences from P to Q
    using 1-nearest neighbors (∀ pᵢ find closest qⱼ)
"""
function correspondence_indxs(P::Vector{Pt}, Q::Vector{Pt})
    correspondances = Tuple{Int, Int}[]

    for (i, p) in enumerate(P)
        min_dist = -Inf
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

function cross_covariance(P, Q, correspondences, kernel= diff -> 1)
    cov = zeros(2,2)
    exclude_indxs = Int[]

    for (i, j) in correspondences
        p = P[i]
        q = Q[j]

        weight = kernel(p - q)
        if weight < 0.01
            push!(exclude_indxs, i)
        end

        cov += weight * q * transpose(p) # (2 x 1 @ 1 x 2 = 2 x 2)
    end

    (cov, exclude_indxs)
end

# function center_data(data)

#     return (center, data - center)
# end


# function icp_iterative(P, Q, iters=25)
#     center_of_Q, Q_centered = center_data(Q)

#     for i=1:iters
#         center_of_P, P_centered = center_data(P)
#         correspondences = get_correspondence_indices(P_centered, Q_centered)

# end
