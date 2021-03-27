function value = vector_interp(p1, p2, a, v1, v2, dim)

    if p1(dim) == p2(dim)
        value = v1;
    else
        l = (p2(dim) - a(dim)) / (p2(dim) - p1(dim));
        value = l * v1 + (1 - l) * v2;
    end
    
end