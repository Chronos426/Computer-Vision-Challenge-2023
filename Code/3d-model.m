data = dlmread('points3D.txt');
x_3d = data(:, 2);
y_3d = data(:, 3);
z_3d = data(:, 4);
ptCloud = pointCloud([x_3d, y_3d, z_3d], 'Color', [1, 1, 1]);

maxDistance = 0.04;
referenceVector_x = [1, 0, 0];
referenceVector_y = [0, 1, 0];
referenceVector_z = [0, 0, 1];
maxAngularDistance = 5;

% Plane 1
[model1, inlierIndices_1, outlierIndices_1] = pcfitplane(ptCloud, maxDistance, referenceVector_z, maxAngularDistance);
plane1 = select(ptCloud, inlierIndices_1);

% Plane 2
[model2, inlierIndices_2, outlierIndices_2] = pcfitplane(ptCloud, maxDistance, referenceVector_x, maxAngularDistance);
plane2 = select(ptCloud, inlierIndices_2);

% Plane 3
[model3, inlierIndices_3, outlierIndices_3] = pcfitplane(ptCloud, maxDistance, referenceVector_y, maxAngularDistance);
plane3 = select(ptCloud, inlierIndices_3);

% Plotting the planes
figure;
pcshow(plane1.Location, 'r');
hold on;
pcshow(plane2.Location, 'g');
pcshow(plane3.Location, 'b');
hold off;
xlabel("X (m)")
ylabel("Y (m)")
zlabel("Z (m)")
title("Detected Planes");
savefig('Detected Planes.fig')


% Compute the alpha shape for each plane
alpha = 1.3;  % Adjust this parameter to control the tightness of the boundary
shp1 = alphaShape(plane1.Location(:, 1), plane1.Location(:, 2), plane1.Location(:, 3), alpha);
shp2 = alphaShape(plane2.Location(:, 1), plane2.Location(:, 2), plane2.Location(:, 3), alpha);
shp3 = alphaShape(plane3.Location(:, 1), plane3.Location(:, 2), plane3.Location(:, 3), alpha);

% Combine the boundary points from all three planes
B1 = boundaryFacets(shp1);
B2 = boundaryFacets(shp2);
B3 = boundaryFacets(shp3);
combinedBoundaryPoints = [shp1.Points(B1(:, 1), :); shp2.Points(B2(:, 1), :); shp3.Points(B3(:, 1), :)];

% Plotting the combined 3D model
figure;
plot3(combinedBoundaryPoints(:, 1), combinedBoundaryPoints(:, 2), combinedBoundaryPoints(:, 3), 'r.');
xlabel("X (m)")
ylabel("Y (m)")
zlabel("Z (m)")
title("Combined 3D Model");
savefig('Combined 3D Model.fig')