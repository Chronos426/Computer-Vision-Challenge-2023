function find_contours_manual(data)
% FIND_CONTOURS Import point cloud
x_3d = data(:, 1);
y_3d = data(:, 2);
z_3d = data(:, 3);
ptCloud = pointCloud([x_3d, y_3d, z_3d], 'Color', [1, 1, 1]);

% Find two-dimensional plane
maxDistance = 0.04;
referenceVector_x = [1,0,0];
referenceVector_y = [0,1,0];
referenceVector_z = [0,0,1];
maxAngularDistance = 5;
[model1,inlierIndices_1,outlierIndices_1] = pcfitplane(ptCloud,...
         maxDistance,referenceVector_z,maxAngularDistance);
plane1 = select(ptCloud,inlierIndices_1);

% % Show original point cloud
% figure;
% pcshow(ptCloud);
% xlabel("X(m)");
% ylabel("Y(m)");
% zlabel("Z(m)");
% title("Original Point Cloud");
% 
% % Show plane1
% figure;
% pcshow(plane1.Location,'r');
% 
% Preprocess obtained plane point cloud
% Extract locations from the point cloud
locations = plane1.Location;
% Define a noise level
noiseLevel = 0.01;
% Add random noise to each location
locationsNoisy = locations + noiseLevel*randn(size(locations));
% Create a new point cloud, containing the noise
ptCloudNoisy = pointCloud(locationsNoisy);
% Use pcdenoise function to find outliers
distanceThreshold = 1; % Set a threshold, you may need to adjust this value according to your data
[outliers, inliers] = pcdenoise(ptCloudNoisy, 'Threshold', distanceThreshold);
% Create a new point cloud, removing the outliers
ptCloudWithoutOutliers = select(ptCloudNoisy, inliers);

% Show original point cloud and noisy point cloud
figure;
pcshow(ptCloudWithoutOutliers);
title('After clicking, you need to press the Enter key');

% 'Manually' draw the outline and return the real world coordinates
set(gca,'color','w');
xlabel("X(m)");
ylabel("Y(m)");
zlabel("Z(m)");
title("Plane 1");
hold on;

% After clicking, you need to press the Enter key
[x_click, y_click] = ginput();

% Draw the contours
plot(x_click,y_click,'LineWidth',2,'Color','b');

% Pause for 2 seconds and then close the figure
pause(2);
close;

hold off;

% Print real world coordinates
disp('X and Y coordinates of clicked points:');
for i = 1:size(x_click, 1)
    fprintf('Corner Point of Contours %d: X = %.2f, Y = %.2f\n', i, x_click(i), y_click(i));
end

% House model
figure;
z_zeros = zeros(size(x_click));
% Base of the house
patch(x_click,y_click,z_zeros,'b');

% Make the figure look 3D
zlim([0, inf]);
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
view(3);

% User selection of two points
disp('Please click on two points on the figure to measure the distance.');
[x_sel, y_sel] = ginput(2);
hold on;
plot(x_sel, y_sel, 'ro');  % plot the selected points

% Calculate and display the distance between the selected points
distance = sqrt((x_sel(2) - x_sel(1))^2 + (y_sel(2) - y_sel(1))^2);

% Print the distance on the figure
midpoint_x = (x_sel(2) + x_sel(1)) / 2;
midpoint_y = (y_sel(2) + y_sel(1)) / 2;
text(midpoint_x, midpoint_y, 0, ['Distance = ', num2str(distance)], 'Color', 'r');

hold off;
end
