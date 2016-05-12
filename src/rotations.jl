export rotation_order

function rotation_order(ord::AbstractString)
    reg = r"^[xzy]{3}$|^[123]{3}$"

    if !ismatch(reg, lowercase(ord))
        throw(ArgumentError("Rotation axes must be indicated as either X, Y, Z or 1, 2, 3."))
    end

    order = replace(replace(replace(lowercase(ord), "x", "1"), "y", "2"), "z", "3")

    if order[1] == order[2] || order[2] == order[3]
        throw(ArgumentError("Subsequent rotations around the same axis are meaningless."))
    end
    parse(Int, order)
end

rotation_order(ord::Int) = rotation_order(string(ord))
