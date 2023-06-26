data = fopen("points3D.txt", "r");
formatString = '%f%f%f%f%f%f%f%f%f%[^\n]';
dataPoints = textscan(data, formatString, 'HeaderLines', 3, 'Delimiter', ' ');
fclose(data);

pointIDs = dataPoints{1};
X = dataPoints{2};
Y = dataPoints{3};
Z = dataPoints{4};
R = dataPoints{5};
G = dataPoints{6};
B = dataPoints{7};
ERROR = dataPoints{8};

% Extracting track information
numPoints = length(pointIDs);
trackData = cell(numPoints, 1);

for i = 1:numPoints
    track = dataPoints{9}(i:end);
    numTrackPoints = numel(track) / 2;
    track = reshape(track, 2, [])';
    trackData{i} = track;
end

% Plotting the 3D points with color and error
figure;
scatter3(X, Y, Z, 10, [R, G, B]/255, 'filled');
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Model with Tracks');

% Adding tracks to the 3D model
hold on;

for i = 1:numPoints
    track = trackData{i};
    numTrackPoints = size(track, 1);
    imageIDs = track(:, 1);
    point2DIndices = track(:, 2);
    
    % Extract the 3D coordinates for the track points
    trackX = X(imageIDs);
    trackY = Y(imageIDs);
    trackZ = Z(imageIDs);
    
    % Plotting the track line
    plot3(trackX, trackY, trackZ, 'r-', 'LineWidth', 1.5);
    
    % Plotting the track points
    scatter3(trackX, trackY, trackZ, 50, 'r', 'filled');
    
    % Adding labels for the track points
    for j = 1:numTrackPoints
        text(trackX(j), trackY(j), trackZ(j), num2str(point2DIndices(j)), 'Color', 'red');
    end
end

hold off;



