function [world_points, inlierIdx, err, valid, all_cam_poses] = reconstruct(data_set, matches, cam_data)
    %% Get number of images
    numImages = numel(data_set);
    
    %% 3D reconstruction
    % Initialize the cell array to store the 3D world points
    world_points = cell(numImages, numImages);
    inlierIdx = cell(numImages, numImages);
    all_cam_poses = cell(numImages, 1);
    pointTracks = [];

    % Initialize waitbar
    h = waitbar(0,'Processing images...');

    totalIterations = (numImages-1)*numImages/2; % total iterations for waitbar
    currentIteration = 0; % current iteration counter


    for i = 1:numImages-1
        for j = i+1:numImages
        % Estimate the fundamental matrix
        try
            [F, inliers] = estimateFundamentalMatrix(matches{i,j}.P1, matches{i,j}.P2, 'Method', 'RANSAC', 'NumTrials', 2500, 'DistanceThreshold', 0.01);
            inlierIdx{i,j} = inliers;
        
            % Compute the essential matrix
            E = cam_data.K' * F * cam_data.K;
            % Extract the inlier points
            inlierPoints1 = matches{i,j}.P1(inliers, :);
            inlierPoints2 = matches{i,j}.P2(inliers, :);
    
            % Estimate the relative pose
            relPose = estrelpose(E, cam_data.Intrinsics, inlierPoints1, inlierPoints2);
    
            % Get projection matrices for the two images
            cameraPose1 = rigidtform3d(eye(3), [0; 0; 0]);
            cameraPose2 = rigidtform3d(eye(3), [0; 0; 0]);
            cameraPose2.R = cameraPose1.R * relPose(1,1).R;
            cameraPose2.Translation = cameraPose1.Translation + relPose(1,1).Translation;
            
            all_cam_poses{i} = cameraPose1;
            all_cam_poses{j} = cameraPose2;

        catch
            % Empty set of inliers
            inlierPoints1 = [];
            inlierPoints2 = [];
        end        

       % Perform triangulation
        if ~isempty(inlierPoints1) && ~isempty(inlierPoints2)  % Check if inliers are not empty
            [world_points{i,j}, err{i,j}, valid] = triangulate(inlierPoints1, inlierPoints2, cameraPose1.A(1:3,:), cameraPose2.A(1:3,:));
            newPointTracks = pointTrack([i j], inlierPoints1.Location);
            pointTracks = [pointTracks; newPointTracks];
        else
            world_points{i,j} = [];  % Empty world points
            err{i,j} = [];  % Empty error
            valid = false;  % Not valid triangulation
        end
        

        % Update waitbar
        fprintf('Loop completed with i = %d and j = %d\n', i, j);
        currentIteration = currentIteration + 1;
        waitbar(currentIteration/totalIterations, h, sprintf('Processing images... %d/%d done', currentIteration, totalIterations));
        end
    end

    % Bundle adjustment
    [optimized_points, optimized_cam_poses] = bundleAdjustment(world_points, pointTracks, all_cam_poses, cam_data.Intrinsics);
    world_points = optimized_points;
    all_cam_poses = optimized_cam_poses;

    % Close waitbar
    close(h);

    
end