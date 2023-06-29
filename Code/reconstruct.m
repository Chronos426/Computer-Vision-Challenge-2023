function [reconstructed_points, inlierIdx] = reconstruct(data_set, matches, cam_data)

    numImages = size(data_set,1);

    % Initialize the cell array to store the 3D world points
    worldPoints = cell(numImages, numImages);
    inlierIdx = cell(numImages, numImages);
    
    cameraPose1 = rigidtform3d(eye(3), [0; 0; 0]);
    cameraPose2 = rigidtform3d(eye(3), [0; 0; 0]);
    
    for i = 1:numImages-1
        % Estimate the fundamental matrix
        [E, inliers] = estimateEssentialMatrix(matches{i,i+1}.P1, matches{i,i+1}.P2,cam_data);
        inlierIdx{i} = inliers;       
        
        % Decompose the essential matrix
        relPose = estrelpose(E,cam_data.Intrinsics,matches{i,i+1}.P1(inliers, :), ...
            matches{i,i+1}.P2(inliers, :));
        
        % Perform triangulationn
        cameraPose1 = cameraPose2;
        cameraPose2 = [cameraPose1.R * relPose.R, cameraPose1.Translation + relPose.Translation];
        [worldPoints{i}, err, valid] = triangulate(matches{i,i+1}.P1(inliers, :), ...
            matches{i,i+1}.P2(inliers, :), cameraPose1, cameraPose2);
    end
    
    % Concatenate all world points into a single array
    reconstructed_points = vertcat(worldPoints{:});

    % Remove points with high reprojection errors (optional)
%     maxReprojError = 5;
%     reconstructed_points(reprojError > maxReprojError, :) = [];
    
    % Visualize the 3D world points
%     pcshow(reconstructed_points, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down', 'MarkerSize', 500);
%     grid on;
%     title('3D Reconstruction');
end