clear all;

% Image preprocessing
imageDir = '/MATLAB Drive/kicker/images/dslr_images_undistorted';
imageFiles = dir(fullfile(imageDir)); % assuming JPEG images
numImages = numel(imageFiles);
images = cell(numImages, 1);
for i = 3:numImages
    images{i} = imread(fullfile(imageDir, imageFiles(i).name));
end

% Feature detection and matching

points = cell(numImages, 1);
features = cell(numImages, 1);
for i = 3:numImages
    grayImage = rgb2gray(images{i});
    points{i} = detectSURFFeatures(grayImage);
    [features{i}, points{i}] = extractFeatures(grayImage, points{i});
end

pairs = nchoosek(3:numImages, 2); % All possible image pairs
matchedPoints = cell(size(pairs, 1), 2);
for i = 1:size(pairs, 1)
    indexPair = pairs(i, :);
    matchPairs = matchFeatures(features{indexPair(1)}, features{indexPair(2)});
    matchedPoints{i, 1} = points{indexPair(1)}(matchPairs(:, 1));
    matchedPoints{i, 2} = points{indexPair(2)}(matchPairs(:, 2));
end

% need to load camera parameter
params = [3410.3, 0, 3121.33; 0, 3409.98,2067.07; 0, 0, 1];

% 3D reconstruction
viewIDs = unique(pairs(:));
views = cell(numel(viewIDs), 1);

for i = 1:numel(viewIDs)
    viewIdx = viewIDs(i);
    view = struct();
    view.Points = matchedPoints{viewIdx, 1};
    % Convert SURF points to XYZ coordinates
    xyPoints = view.Points.Location;
    xyzPoints = (params \ [xyPoints, ones(size(xyPoints, 1), 1)]')';

    % Shift XYZ coordinates to ensure positive values
    minXYZ = min(xyzPoints(:, 1:3), [], 1);
    xyzPoints = xyzPoints - minXYZ + 1;

    view.Points = xyzPoints(:, 1:3);

    view.ProjectionMatrix = params * [eye(3), zeros(3, 1)]; 
    views{i} = view;

end

% works till here, need to change bundleAdjustment function's input
% accroding to documentation
% struct = bundleAdjustment(views, matchedPoints, params);

% Refinement (optional)
% struct = refine3DStructure(struct, matchedPoints, params);

% Concatenate all points
allPoints = cat(1, views{:}).Points;

% Create point cloud object
ptCloud = pointCloud(allPoints);

% Display the 3D model
figure;
pcshow(ptCloud);
xlabel('X');
ylabel('Y');
zlabel('Z');
% measurement of distence
