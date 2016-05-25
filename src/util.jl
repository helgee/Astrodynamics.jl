function neighbors(t, root=Any)
    supertype = super(t)
    if supertype == root
        return subtypes(t)
    else
        return push!(subtypes(t), supertype)
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

log(str) = println("[Astrodynamics.jl] $str")
