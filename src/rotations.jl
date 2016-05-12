export rotation_axes

function rotation_axes(ord::AbstractString)
    if !(length(ord) == 1 || length(ord) == 3)
        throw(ArgumentError("Please provide either a triple of axes or a single rotation axis."))
    end

    reg = r"^[xzy]{1,3}$|^[123]{1,3}$"

    if !ismatch(reg, lowercase(ord))
        throw(ArgumentError("Rotation axes must be indicated as either X, Y, Z or 1, 2, 3."))
    end

    order = replace(replace(replace(lowercase(ord), "x", "1"), "y", "2"), "z", "3")

    if length(order) == 3 && (order[1] == order[2] || order[2] == order[3])
        throw(ArgumentError("Subsequent rotations around the same axis are meaningless."))
    end
    parse(Int, order)
end

rotation_axes(ord::Int) = rotation_axes(string(ord))
