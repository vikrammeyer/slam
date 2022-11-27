
function translation_vec_to_homogenous_matrix(t::Vector)
    matrix = Matrix(1I, 3, 3)
    matrix[1,end] = t[1]
    matrix[2,end] = t[2]
    return matrix
end

function rotation_matrix_to_homogenous_matrix(R::Matrix)
    matrix = Matrix(1I, 3, 3)
    matrix[1:2, 1:2] = R
    return matrix
end

function homoegenous_to_cartesian(x, y, w)
    return (x / w, y / w)
end