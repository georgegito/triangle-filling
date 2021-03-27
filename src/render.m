function Img = render(vertices_2d, faces, vertex_colors, depth, renderer)
    
    Img(1:1200, 1:1200, 1:3) = 1;
    tr_num = size(faces, 1);

    %% compute depth of each triangle
    tr_depth = zeros(1, tr_num);
    
    for i = 1:tr_num
        tr_depth(i) = mean(depth(faces(i, 1:3)));
    end
    
    %% sort triangles by depth
    [tr_depth, tr_idx] = sort(tr_depth ,'descend');
    
    %% paint triangles by descending depth
    for i = 1:tr_num
        if renderer == 1
            Img = paint_triangle_flat(   Img, ... 
                                                              vertices_2d(faces(tr_idx(i), 1:3), 1:2), ... 
                                                              vertex_colors(faces(tr_idx(i), 1:3), 1:3)   );
        elseif renderer == 2
            Img = paint_triangle_gouraud(   Img, ... 
                                                              vertices_2d(faces(tr_idx(i), 1:3), 1:2), ... 
                                                              vertex_colors(faces(tr_idx(i), 1:3), 1:3)   );
        end
    end
end