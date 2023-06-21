function [matches] = feat_extract_match(imageData)
%% Feature extraction
    tic
    % Convert the images to grayscale if needed
    grayImageData = cellfun(@(x) rgb2gray(x), imageData, 'UniformOutput', false);
    
    % Create an empty cell array to store the SURF features
    surfFeatures = cell(numel(imageData), 1);
    
    % Extract SURF features from each imagess
    for i = 1:numel(imageData)
        % Extract SURF features
        surfFeatures{i} = detectSURFFeatures(grayImageData{i});
        
        fprintf('SIFT features progress %d%%\n', ceil((i/numel(imageData))*100));
    end
    
    % Display the number of images processed
    fprintf('SIFT features extracted for %d images\n', numel(surfFeatures));
    toc
%% Feature matching
	tic

    numImages = length(surfFeatures);
    matches = cell(numImages, numImages);
    p = 0;
    m = (numImages-1)/2*numImages;

    fprintf('Number of matches to calculate %d \n', m);
    
    for i = 1:numImages

        % Perform feature matching with the remaining images
        for j = i+1:numImages

            [f1,v1] = extractFeatures(grayImageData{i},surfFeatures{i});
            [f2,v2] = extractFeatures(grayImageData{j},surfFeatures{j});

            indexPairs = matchFeatures(f1, f2);

            matchedPoints1 = v1(indexPairs(:,1));
            matchedPoints2 = v2(indexPairs(:,2));

            matches{i,j} = struct('P1', matchedPoints1,'P2' , matchedPoints2);
            p = p + 1;
            fprintf('Progress: %d%%\n', ceil((p / m)*100));
        end
    end
    fprintf('Features matched. \n');
    toc

end
