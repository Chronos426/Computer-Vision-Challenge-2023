% This function is for reconstructing a 3D model from multiple images.
% It uses SURF features, fundamental matrix, essential matrix, relative pose estimation, triangulation,
% and multiview reconstruction for this purpose.

% Inputs:
%   - data_set: A cell array where each cell is an RGB image.
%   - cam_data: A structure containing camera parameters, e.g., Intrinsics and K

% Outputs:
%   - xyzPoints: The 3D points reconstructed from the images.
%   - errors: Reprojection errors associated with the 3D points.

function [xyzPoints,errors] = reconstruction(data_set, cam_data)

    % The total number of images
    numImages = uint32(numel(data_set));
    gray_images = cell(numel(data_set));

    % Convert all images to grayscale
    for k = 1:numImages
        gray_images{k} = rgb2gray(data_set{k});
        % gray_images{k} = undistortImage(gray_images{k}, cam_data.Intrinsics);
    end

    % Initialize an image view set to manage the data associated with each view
    vSet = imageviewset;

    % Create a camera pose for the first image, assuming that it is at the origin
    cameraPoses(1) = rigidtform3d(eye(3), [0; 0; 0]);

    % Compute SURF features for the first image
    pointsPrev = detectSURFFeatures(gray_images{1});
    [featuresPrev, pointsPrev] = extractFeatures(gray_images{1}, pointsPrev);

    % Add the computed features to the view set
    vSet = addView(vSet,1,cameraPoses(1),'Points', pointsPrev);

    % Loop through the rest of the images
    for i = 2:numImages
        % Compute SURF features for the current image
        points = detectSURFFeatures(gray_images{i});
        [features, points] = extractFeatures(gray_images{i}, points);

        % Match features between the previous and current images
        pairsIdx = matchFeatures(featuresPrev, features, 'MatchThreshold',5);
        matchedPoints1 = pointsPrev(pairsIdx(:,1));
        matchedPoints2 = points(pairsIdx(:,2));
        matches{i-1} = struct('P1', matchedPoints1, 'P2', matchedPoints2);

        % % Estimate fundamental matrix between the matched points
        % [F, inliers] = estimateFundamentalMatrix(matches{i-1}.P1, matches{i-1}.P2, "Method","Norm8Point","NumTrials",10000,"Confidence", 90);
        % 
        % % Compute essential matrix
        % E = cam_data.K' * F * cam_data.K;

        % Estimate Essential matrix
        [E, inliers] = estimateEssentialMatrix(matches{i-1}.P1, matches{i-1}.P2, cam_data.Intrinsics, cam_data.Intrinsics, "Confidence", 90, "MaxNumTrials", 10000, "MaxDistance", 0.5);

        % Get inlier points
        inlierPoints1 = matches{i-1}.P1(inliers,:);
        inlierPoints2 = matches{i-1}.P2(inliers,:);

        % Estimate relative pose
        relPose = estrelpose(E,cam_data.Intrinsics, inlierPoints1, inlierPoints2);

        % Update camera pose for the current image
        cameraPoses(i) = cameraPoses(i-1);
        cameraPoses(i).R = cameraPoses(i-1).R * relPose(1,1).R;
        cameraPoses(i).Translation = cameraPoses(i-1).Translation + relPose(1,1).Translation;

        % Add computed features and relative pose to the view set
        vSet = addView(vSet,i, cameraPoses(i), 'Points', points);
        vSet = addConnection(vSet, i-1, i, 'Matches', pairsIdx);

        % Update the features and points for the next iteration
        featuresPrev = features;
        pointsPrev = points;
    end

    % Find point tracks spanning multiple views
    tracks = findTracks(vSet);

    % Convert camera poses to a table
    cameraPoses = table((1:numImages)', cameraPoses','VariableNames', {'ViewId', 'AbsolutePose'});

    % Reconstruct the 3D scene
    [xyzPoints, errors] = triangulateMultiview(tracks, cameraPoses, cam_data.Intrinsics);

    % Perform bundle adjustment
    [xyzPoints, cameraPoses] = bundleAdjustment(xyzPoints, tracks, cameraPoses, cam_data.Intrinsics, 'AbsoluteTolerance', 1e-9, 'RelativeTolerance', 1e-9, 'MaxIterations', 500);
 
    % Filter 3D points using error metrics and depth constraints
    x = xyzPoints(:,1);
    y = xyzPoints(:,2);
    z = xyzPoints(:,3);    
    idx = errors < 10 & z > 0 & z < 20 & x > -40 & x < 40 & y > -40 & y < 40;
    xyzPoints = xyzPoints(idx, :);
    
    % Display the 3D point cloud
    pcshow(xyzPoints,'AxesVisibility',"on",'VerticalAxis',"y",'VerticalAxisDir',"down",'MarkerSize',30);

    % Display the camera poses
    hold on
    plotCamera(cameraPoses, 'Size',0.2);
    hold off
end

