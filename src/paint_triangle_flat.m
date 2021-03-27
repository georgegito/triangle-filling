function Y = paint_triangle_flat(img, vertices_2d, vertex_colors)

    %% compute color
    color = [mean(vertex_colors(1:3, 1)), mean(vertex_colors(1:3, 2)), mean(vertex_colors(1:3, 3))];

    %% swap rows and cols
    vertices_2d = [vertices_2d(:, 2), vertices_2d(:, 1)];

    %% find edges
    for e = 1:3
        edges(e).vertices = [vertices_2d(e, 1:2); vertices_2d(mod(e, 3) + 1, 1:2)];
        edges(e).x_min = min(edges(e).vertices(1:2, 1));
        edges(e).x_max = max(edges(e).vertices(1:2, 1));
        edges(e).y_min = min(edges(e).vertices(1:2, 2));
        edges(e).y_max = max(edges(e).vertices(1:2, 2));
        edges(e).m = (edges(e).vertices(1, 2) - edges(e).vertices(2, 2)) / (edges(e).vertices(1, 1) - edges(e).vertices(2, 1));
    end
    
    %% find triangle lower and upper bounds
    y_min = min([edges(:).y_min]);
    y_max = max([edges(:).y_max]);

    %% init variables
    active_edges_nums = [];
    lowest_hor_edge = false;
    
    %% find the initial active edges
    for e = 1:3
        if y_min == edges(e).y_min
            if edges(e).m ~= 0
                active_edges_nums = [active_edges_nums, e];
            else
                lowest_hor_edge = true;  
            end
        end
    end
    
    if length(active_edges_nums) == 0 || length(active_edges_nums) == 1
        Y = img;
        return;
    end

    %% find the initial active x
    if lowest_hor_edge == false
        for i = 1:3
            if vertices_2d(i, 2) == y_min
                x1_active  = vertices_2d(i, 1);
                x2_active = x1_active;
            end
        end
        %% paint the lowest vertex
        img(floor(x1_active + 0.5), floor(y_min + 0.5), 1:3) = color;
    else
        % case of lowest horizontal edge
        if edges(active_edges_nums(1)).vertices(1, 2) == edges(active_edges_nums(1)).y_min
            x1_active = edges(active_edges_nums(1)).vertices(1, 1);
        else
            x1_active = edges(active_edges_nums(1)).vertices(2, 1);
        end
        if edges(active_edges_nums(2)).vertices(1, 2) == edges(active_edges_nums(2)).y_min
            x2_active = edges(active_edges_nums(2)).vertices(1, 1);
        else
            x2_active = edges(active_edges_nums(2)).vertices(2, 1);
        end
       %% paint the lowest horizontal edge
        for x = min(x1_active, x2_active):max(x1_active, x2_active)
           img(floor(x + 0.5), floor(y_min + 0.5), 1:3) = color;
       end
    end
    
    %% scan the lines of the triangle
    for y = (y_min + 1):(y_max)
        
        %% udpate active x bounds
        if ~isinf(edges(active_edges_nums(1)).m)
            x1_active = x1_active + 1 / edges(active_edges_nums(1)).m;
        end
        if ~isinf(edges(active_edges_nums(2)).m)
            x2_active = x2_active + 1 / edges(active_edges_nums(2)).m;
        end

        %% paint the line between active x bounds
        for x = min(x1_active, x2_active):max(x1_active, x2_active)
           img(floor(x + 0.5), y, 1:3) = color;
        end
        
        %% if one of the active edges finishes, check for the next active
        % edge and replace the current
        if y == edges(active_edges_nums(1)).y_max
            for e = 1:3
                if y == edges(e).y_min
                    active_edges_nums(1) = e;
                end
            end
        elseif y == edges(active_edges_nums(2)).y_max
            for e = 1:3
                if y == edges(e).y_min
                    active_edges_nums(2) = e;
                end
            end
        end
    end

    Y = img;
end