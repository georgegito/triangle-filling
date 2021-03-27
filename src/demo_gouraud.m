close all;
load('racoon_hw1.mat');

renderer = 2;
Img = render(vertices_2d, faces, vertex_colors, depth, renderer);

figure;
imshow(Img);

imwrite(Img, 'racoon_gouraud.png')