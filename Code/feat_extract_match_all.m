function [matches] = feat_extract_match_all(imageData)
    % Initialize the matches cell array
    matches = cell(length(imageData), length(imageData));
    
    % Create a waitbar
    h = waitbar(0, 'Initializing...');
    
    % Calculate the total number of iterations
    totalIterations = nchoosek(length(imageData), 2);
    
    % Initialize a counter for the current iteration
    currentIteration = 0;
    % Loop over the pairs of images
    for i = 1:(length(imageData)-1)
        for j = i+1:length(imageData)
            
            % Update the waitbar
            waitbar(currentIteration / totalIterations, h, sprintf('Processing pair %d, %d...', i, j));
            
            % Get the current pair of images
            img1 = imageData{i};
            img2 = imageData{j};
            
            % Convert the images to grayscale
            img1_gray = rgb2gray(img1);
            img2_gray = rgb2gray(img2);
    
            % Detect SURF features
            points1 = detectSURFFeatures(img1_gray);
            points2 = detectSURFFeatures(img2_gray);
            
            % Extract feature descriptors
            [features1, validPoints1] = extractFeatures(img1_gray, points1);
            [features2, validPoints2] = extractFeatures(img2_gray, points2);
            
            % Find matching features
            indexPairs = matchFeatures(features1, features2);
            
            % Retrieve the locations of the matched points
            matchedPoints1 = validPoints1(indexPairs(:, 1));
            matchedPoints2 = validPoints2(indexPairs(:, 2));
            
            % Store the matched points
            matches{i, j} = {matchedPoints1, matchedPoints2};
            
            % Increment the current iteration counter
            currentIteration = currentIteration + 1;
        end
    end
% Close the waitbar
close(h);
end