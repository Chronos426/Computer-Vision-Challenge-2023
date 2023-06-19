function [data_set,cam_data] = dataloader
    % Prompt the user to select the folder containing the images
    folderPath = uigetdir('Select the folder containing the images');
    
    % Get a list of all files in the folder
    fileList = dir(fullfile(folderPath, '*.jpg')); 
    
    % Create a cell array to store the images
    data_set = cell(numel(fileList), 1);
    
    % Read and store each image in the cell array
    for i = 1:numel(fileList)
        % Construct the full file path
        filePath = fullfile(folderPath, fileList(i).name);
        
        % Read the image
        data_set{i} = imread(filePath);
    end
    
    % Display the number of images loaded
    fprintf('Total images loaded: %d\n', numel(data_set));
    
    cam_data = 0; % Temporary, has to be implemented

end
