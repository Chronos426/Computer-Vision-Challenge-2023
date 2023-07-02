 data = dlmread('points3D.txt');
x = data(:, 2);
y = data(:, 3);
z = data(:, 4);

% Extract the RGB values
r = data(:, 5)/ 255;
g = data(:, 6)/ 255;
b = data(:, 7)/ 255;

% Create a point cloud with RGB information
ptCloud = pointCloud([x, y, z], 'Color', [r, g, b]);

% Display the point cloud
pcshow(ptCloud);
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Point Cloud');

% Surface reconstruction and denoising
% Not a big difference
reconstructedSurface = pcdenoise(ptCloud);
pcshow(reconstructedSurface);
title('Reconstructed Surface'); 