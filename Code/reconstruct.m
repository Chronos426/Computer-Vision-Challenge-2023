function [reconstructed_points, inlierIdx] = reconstruct(data_set, matches, cam_data)
    %% Get number of images
    numImages = size(data_set,1);
    
    %% 3D reconstruction
    % Initialize the cell array to store the 3D world points
    worldPoints = cell(numImages, numImages);
    inlierIdx = cell(numImages, numImages);
    
    for i = 1:numImages-1
        % Estimate the fundamental matrix
        [F, inliers] = estimateFundamentalMatrix(matches{i}.P1, matches{i}.P2, 'Method', 'MSAC', 'NumTrials', 2000);
        inlierIdx{i} = inliers;
        
        % Compute the essential matrix
        E = cam_data.K' * F * cam_data.K;
        
        % Decompose the essential matrix
        [Rot, trans] = relativeCameraPose(E, cam_data.K, matches{i}.P1(inliers, :), matches{i}.P2(inliers, :));
        
        % Perform triangulation
        cameraPose1 = [eye(3), [0; 0; 0]];
        cameraPose2 = [Rot, trans];
        [worldPoints{i}, ~] = triangulate(matches{i}.P1(inliers, :), matches{i}.P2(inliers, :), cameraPose1, cameraPose2);
    end
    
    % Concatenate all world points into a single array
    reconstructed_points = vertcat(worldPoints{:});

    % Remove points with high reprojection errors (optional)
    maxReprojError = 5;
    reconstructed_points(reprojError > maxReprojError, :) = [];
    
    % Visualize the 3D world points
    pcshow(reconstructed_points, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down', 'MarkerSize', 500);
    grid on;
    title('3D Reconstruction');
end