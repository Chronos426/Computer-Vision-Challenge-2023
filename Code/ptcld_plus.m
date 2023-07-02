data = dlmread('points3D.txt');
x = data(:, 2);
y = data(:, 3);
z = data(:, 4);

% Extract the RGB values and normalize them
r = data(:, 5) / 255;
g = data(:, 6) / 255;
b = data(:, 7) / 255;

% Create a point cloud with RGB information
ptCloud = pointCloud([x, y, z], 'Color', [r, g, b]);

% Step 1:
pointCloudData = [x, y, z, r, g, b]; % Combine the x, y, z coordinates with RGB values
normalizedRGB = pointCloudData(:, 4:6);

% Determine the range of x, y, and z coordinates
xMin = min(pointCloudData(:, 1));
xMax = max(pointCloudData(:, 1));
yMin = min(pointCloudData(:, 2));
yMax = max(pointCloudData(:, 2));
zMin = min(pointCloudData(:, 3));
zMax = max(pointCloudData(:, 3));


% Step 2: Image Initialization
width = round(xMax - xMin + 1); % Width of the image
height = round(yMax - yMin + 1); % Height of the image
image = zeros(height, width, 3); % Initialize the image

% Define a color mapping function
mapColorToPixel = @(x, y, z) [round(x - xMin + 1), round(y - yMin + 1)];

% Step 3: Point Cloud to Image Conversion
numPoints = size(pointCloudData, 1);
for i = 1:numPoints
    x = pointCloudData(i, 1);
    y = pointCloudData(i, 2);
    z = pointCloudData(i, 3);
    r = normalizedRGB(i, 1);
    g = normalizedRGB(i, 2);
    b = normalizedRGB(i, 3);

    % Calculate the pixel location
    pixelLocation = mapColorToPixel(x, y, z);
    pixelX = pixelLocation(1);
    pixelY = pixelLocation(2);

    % Assign RGB values to the corresponding pixel in the image
    image(pixelY, pixelX, :) = [r, g, b];
end

% Step 4: Visualization
imshow(image);
title('Reconstructed Image');

% Display the original point cloud
figure;
pcshow(ptCloud);
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Original 3D Point Cloud');

% Perform surface reconstruction and denoising
reconstructedSurface = pcdenoise(ptCloud);
figure;
pcshow(reconstructedSurface);
title('Reconstructed Surface');