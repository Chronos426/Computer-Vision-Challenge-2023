function [surfFeatures] = feature_extraction(imageData)
    % Convert the images to grayscale if needed
    grayImageData = cellfun(@(x) rgb2gray(x), imageData, 'UniformOutput', false);
    
    % Create an empty cell array to store the SURF features
    surfFeatures = cell(numel(imageData), 1);
    
    % Extract SURF features from each image
    for i = 1:numel(imageData)
        % Extract SURF features
        surfFeatures{i} = detectSURFFeatures(grayImageData{i});
        
        fprintf('SIFT features progress %d%%\n', (i/numel(imageData))*100);
    end
    
    % Display the number of images processed
    fprintf('SIFT features extracted for %d images\n', numel(surfFeatures));
end