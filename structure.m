% Image preprocessing
imageDir = 'path/to/image/directory';
imageFiles = dir(fullfile(imageDir, '*.JPD')); % assuming JPEG images
numImages = numel(imageFiles);
images = cell(numImages, 1);
for i = 1:numImages
    images{i} = imread(fullfile(imageDir, imageFiles(i).name));
end

% Feature detection and matching
points = cell(numImages, 1);
features = cell(numImages, 1);
for i = 1:numImages
    grayImage = rgb2gray(images{i});
    points{i} = detectSURFFeatures(grayImage); 
    % try harris, surff better
    [features{i}, points{i}] = extractFeatures(grayImage, points{i});
end

pairs = nchoosek(1:numImages, 2); % All possible image pairs
matchedPoints = cell(size(pairs, 1), 2);

for i = 1:size(pairs, 1)
    indexPair = pairs(i, :);
    matchPairs = matchFeatures(features{indexPair(1)}, features{indexPair(2)});
    matchedPoints{i, 1} = points{indexPair(1)}(matchPairs(:, 1));
    matchedPoints{i, 2} = points{indexPair(2)}(matchPairs(:, 2));
end

% Camera calibration
[imagePoints, boardSize] = detectCheckerboardPoints(images);
squareSize = 30; % Size of checkerboard square in mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
params = estimateCameraParameters(imagePoints, worldPoints);

% 3D reconstruction
viewIDs = unique(pairs(:));
views = cell(numel(viewIDs), 1);
for i = 1:numel(viewIDs)
    viewIdx = viewIDs(i);
    view = struct();
    view.Points = matchedPoints{viewIdx, 1};
    view.ProjectionMatrix = params.CameraParameters1.IntrinsicMatrix * [eye(3), zeros(3, 1)]; % Assuming camera 1 as reference
    views{i} = view;
end

structure = bundleAdjustment(views, matchedPoints, params);

% Refinement (optional)
structure = refine3DStructure(structure, matchedPoints, params);

% Display the 3D model
figure;
pcshow(structure.Points, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down');
xlabel('X');
ylabel('Y');
zlabel('Z');

% measurement of distence