clear all;

% Image preprocessing
imageDir = '/Users/xiaochuanma/Desktop/Computer-Vision-Challenge-2023/example_kicker/images';
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
    view.ProjectionMatrix = params * [eye(3), zeros(3, 1)]; 
    views{i} = view;

end

% works till here, need to change bundleAdjustment function's input
% accroding to documentation
% struct = bundleAdjustment(views, matchedPoints, params);

% Refinement (optional)
% struct = refine3DStructure(struct, matchedPoints, params);

% Display the 3D model
% Surffpoints unable to display using pcshow, need to convert to xy-points
figure;
pcshow(views.Points, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down');
xlabel('X');
ylabel('Y');
zlabel('Z');
% measurement of distence
