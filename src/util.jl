using Compat

export Optional

typealias Optional{T} Union{T, Nullable{T}}

function neighbors(t, root=Any)
    super = supertype(t)
    if super == root
        return subtypes(t)
    else
        return push!(subtypes(t), super)
    end
end

function findpath(origin, target, root=Any)
    queue = [origin]
    links = Dict{DataType, DataType}()
    while !isempty(queue)
        node = shift!(queue)
        if node == target
            break
        end
        for n in neighbors(node, root)
            # Handle parametric types like IAU{Earth}
            if target <: n && isempty(subtypes(n))
                n = target
            end
            if !haskey(links, n)
                push!(queue, n)
                merge!(links, Dict{DataType, DataType}(n=>node))
            end
        end
    end
    if !haskey(links, target)
        error("No conversion path '$origin' -> '$target' found.")
    end
    path = [target]
    node = target
    while node != origin
        push!(path, links[node])
        node = links[node]
    end
    return reverse(path)
end

message(str) = println("[Astrodynamics.jl] $str")

magnitude(x) = x ≈ 0.0 ? 1.0 : floor(log10(abs(x))) + 1.0
