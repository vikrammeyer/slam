""" Implement ICP algorithm using SVD here
    https://nbviewer.org/github/niosus/notebooks/blob/master/icp.ipynb
"""


function center_data(data)

    return (center, data - center)




function icp_iterative(P, Q, iters=25)
    center_of_Q, Q_centered = center_data(Q)

    for i=1:iters
        center_of_P, P_centered = center_data(P)
        correspondences = get_correspondence_indices(P_centered, Q_centered)
