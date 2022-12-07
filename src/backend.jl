""" Construct the pose graph and solve using Caesar
"""
# using Caesar




function test_loop_closer(lasers, currentIdx, currentPoints; normThreshold = 3.0) #normThreshold needs to be experimented with
    landmarkIdx = nothing
    tf_mtx = nothing
    P = nothing
    closeFlag = false
    for (idx, points) in enumerate(lasers[1:end-1])
        tf_mtx, P, l2_norm = icp_svd(points, currentPoints)
        if l2_norm < normThreshold
            landmarkIdx = idx
            closeFlag = true
            println("norm l2 $l2_norm of landmarkIdx $landmarkIdx, current $currentIdx")
            break
        end
    end 
    return currentIdx, landmarkIdx, P, tf_mtx, closeFlag
end


function norm_scans(P, Q)
    total = 0.
    for p in P, q in Q
        total += sum((p - q).^2)
    end
    sqrt(total)
end


function norm_points(P, Q)
    total = 0
    for (p, q) in zip(P, Q)
        total += sum((p - q).^2)
    end
    return sqrt(total)
end