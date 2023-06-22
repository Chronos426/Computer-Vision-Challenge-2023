function [data_set,cam_data,im_data] = dataloader
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

    [baseName, folder] = uigetfile('*.txt', 'Select camera txt');
    path = fullfile(folder, baseName);
    filecontent = readtable(path);

    k = table2array(filecontent(2,end-5:end)); 
    K = [k(3) 0 k(5);0 k(4) k(6);0 0 1];
    sz = [k(1),k(2)];
    cam_data = cameraParameters("K",K,"ImageSize",sz);

    %% Load the Image Parameters (Not sure how the format is)
    [baseName, folder] = uigetfile('*.txt', 'Select image txt');
    path = fullfile(folder, baseName);
    filecontent = readtable(path);
    sz = size(filecontent,1);
    
    im_data = zeros(sz,3);
    content = table2array(filecontent(:,1:4));

    for i = 1:sz
        im_data(content(i,1),:) = content(i,2:4);
    end
    toc

end
