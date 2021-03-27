function Y = paint_triangle_gouraud(img, vertices_2d, vertex_color)

    %% swap rows and cols
    vertices_2d = [vertices_2d(:, 2), vertices_2d(:, 1)];

    %% paint vertices
    for v = 1:3
        img(vertices_2d(v, 1), vertices_2d(v,2), 1:3) = vertex_color(v, 1:3);
    end
    
    %% find edges
    for e = 1:3
        edges(e).vertices = [vertices_2d(e, 1:2); vertices_2d(mod(e, 3) + 1, 1:2)];
        edges(e).y_min = min(edges(e).vertices(1:2, 2));
        edges(e).y_max = max(edges(e).vertices(1:2, 2));
        edges(e).m = (edges(e).vertices(1, 2) - edges(e).vertices(2, 2)) / (edges(e).vertices(1, 1) - edges(e).vertices(2, 1));
        edges(e).vertex_color = [vertex_color(e, 1:3); vertex_color(mod(e, 3) + 1, 1:3)];
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
    else
        if edges(active_edges_nums(1)).vertices(1, 2) == edges(active_edges_nums(1)).y_max
            x1_active = edges(active_edges_nums(1)).vertices(2, 1);
        else
            x1_active = edges(active_edges_nums(1)).vertices(1, 1);
        end
        if edges(active_edges_nums(2)).vertices(1, 2) == edges(active_edges_nums(2)).y_max
            x2_active = edges(active_edges_nums(2)).vertices(2, 1);
        else
            x2_active = edges(active_edges_nums(2)).vertices(1, 1);
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
        x_min = floor(min(x1_active, x2_active) + 0.5);
        x_max = floor(max(x1_active, x2_active) + 0.5);

        img(x_min:x_max, y, 1:3) = ...
            paint_line_gouraud( edges, ...
                                                    active_edges_nums, ...
                                                    y, ...
                                                    x1_active, ...
                                                    x2_active, ...
                                                    img );
                                                
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