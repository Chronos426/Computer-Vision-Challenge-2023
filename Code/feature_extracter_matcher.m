function matches = feature_extracter_matcher(imageData)

    % Initialize the matches cell array
    matches = cell(length(imageData)-1, 1);
    
    % Loop over the pairs of images
    for idx = 1:(length(imageData)-1)
        
        % Get the current pair of images
        img1 = imageData{idx};
        img2 = imageData{idx+1};
        
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
        matches{idx} = {matchedPoints1, matchedPoints2};
    end
end