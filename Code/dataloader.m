    function [data_set,cam_data,im_data] = dataloader
%% Load the images
    % Prompt the user to select the folder containing the images
    folderPath = uigetdir('Select the folder containing the images');
    
    tic
    % Get a list of all files in the folder
    fileList = dir(fullfile(folderPath, '*.JPG')); 
    
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

    k = table2array(filecontent(2,3:end));
    IntrinsicMatrix = [k(3) 0 k(5); 0 k(4) k(6); 0 0 1];
    sz = [k(1),k(2)];
    try
        cam_data = cameraParameters('K',IntrinsicMatrix,'ImageSize',sz);
    catch
        cam_data = cameraParameters('IntrinsicMatrix',IntrinsicMatrix,'ImageSize',sz);
    end
    %% Load the Image Parameters (Not sure how the format is)
    [baseName, folder] = uigetfile('*.txt', 'Select image txt');
    path = fullfile(folder, baseName);
    fid = fopen(path, 'r');
    for i = 1:4
        fgetl(fid); 
    end
    
    im_data = struct('IMAGE_ID', {}, 'QW', {}, 'QX', {}, 'QY', {}, 'QZ', {}, 'TX', {}, 'TY', {}, 'TZ', {}, 'CAMERA_ID', {}, 'NAME', {}, 'POINTS2D', {});

    imageCount = 0; % Initialize image counter
    while ~feof(fid)
        % Read one line of the image data and split it into elements
        imageLine = strsplit(fgetl(fid));
        
        % Store elements into the structure
        imageCount = imageCount + 1;
        im_data(imageCount).IMAGE_ID = str2double(imageLine{1});
        im_data(imageCount).QW = str2double(imageLine{2});
        im_data(imageCount).QX = str2double(imageLine{3});
        im_data(imageCount).QY = str2double(imageLine{4});
        im_data(imageCount).QZ = str2double(imageLine{5});
        im_data(imageCount).TX = str2double(imageLine{6});
        im_data(imageCount).TY = str2double(imageLine{7});
        im_data(imageCount).TZ = str2double(imageLine{8});
        im_data(imageCount).CAMERA_ID = str2double(imageLine{9});
        im_data(imageCount).NAME = imageLine{10};
        
        % Read the second line of points data for each image and split it into elements
        pointsLine = strsplit(fgetl(fid));
        
        % Reshape the pointsLine into a 3xN array
        pointsData = reshape(str2double(pointsLine), 3, []).';
        
        % Store the points data into the structure
        im_data(imageCount).POINTS2D = pointsData;
    end
    fclose(fid);
end