function [data_set,cam_data] = dataloader
%% Load the images
    % Prompt the user to select the folder containing the images
    folderPath = uigetdir('Select the folder containing the images');
    
    tic
    % Get a list of all files in the folder
    fileList = dir(fullfile(folderPath, '*.jpg')); 
    
    % Create a cell array to store the images
    data_set = cell(numel(fileList), 1);
    
    % Read and store each image in the cell array
    for i = 1:numel(fileList)
        % Construct the full file path
        filePath = fullfile(folderPath, fileList(i).name);

        data_set{i} = imread(filePath);
    end
    % Display the number of images loaded
    fprintf('Total images loaded: %d\n', numel(data_set));

%% Load the Camera Parameters 

    [baseName, folder] = uigetfile('*.txt', 'Select a text file');
    path = fullfile(folder, baseName);
    
    filecontent = readtable(path);
    cam_data = filecontent(:,end-11:end); % This line works only for the eh3 data set

    toc

end
