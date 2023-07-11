function find_contours_auto(data)

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

%% 'Automatically' draws the outline and returns the real world coordinates
X = double(ptCloudWithoutOutliers.Location(:,1));
Y = double(ptCloudWithoutOutliers.Location(:,2));
% Compute the alpha shape
alpha = 1.3;  % Adjust this parameter to control the tightness of the boundary
shp = alphaShape(X, Y, alpha);

% Extract the boundary points
B = boundaryFacets(shp);

% Get the points on the boundary
boundaryPoints = shp.Points(B(:,1), :);

% Plot the 2D polygon boundary
z_zeros = zeros(size(boundaryPoints(:,2)));
% Base of the structure
patch(boundaryPoints(:,1),boundaryPoints(:,2),z_zeros,'b');

% Make the figure look 3D
zlim([0, inf]);
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
view(3);
end
