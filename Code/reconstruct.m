function [world_points, inlierIdx] = reconstruct(data_set, matches, cam_data, im_data)
    %% Get number of images
    numImages = numel(data_set);
    
    %% 3D reconstruction
    % Initialize the cell array to store the 3D world points
    world_points = cell(numImages, numImages);
    inlierIdx = cell(numImages, numImages);
    
    % Initialize waitbar
    h = waitbar(0,'Processing images...');

    totalIterations = (numImages-1)*numImages/2; % total iterations for waitbar
    currentIteration = 0; % current iteration counter

    for i = 1:numImages-1
        for j = i+1:numImages
        % Estimate the fundamental matrix
        [F, inliers] = estimateFundamentalMatrix(matches{i,j}.P1, matches{i,j}.P2, 'Method', 'RANSAC', 'NumTrials', 5000, 'DistanceThreshold', 0.01);
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


        % Perform triangulationn
        [world_points{i,j}, err, valid] = triangulate(matches{i,j}.P1(inliers, :), matches{i,j}.P2(inliers, :), cameraPose1.A(1:3,:), cameraPose2.A(1:3,:));
        % Update waitbar
        fprintf('Loop completed with i = %d and j = %d\n', i, j);
        currentIteration = currentIteration + 1;
        waitbar(currentIteration/totalIterations, h, sprintf('Processing images... %d/%d done', currentIteration, totalIterations));
        
        end
    end
    % Close waitbar
    close(h);
    % %% Concatenate all world points into a single array
    % reconstructed_points = vertcat(world_points{:});
    % 
    % % Remove points with high reprojection errors (optional)
    % % maxReprojError = 5;
    % % reconstructed_points(reprojError > maxReprojError, :) = [];
    % 
    % % Visualize the 3D world points
    % pcshow(reconstructed_points, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down', 'MarkerSize', 500);
    % grid on;
    % title('3D Reconstruction');
end