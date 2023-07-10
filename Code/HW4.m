% Homework 4
%% 4.1
function [T1, R1, T2, R2, U, V] = TR_from_E(E)
    % This function calculates the possible values for T and R 
    % from the essential matrix

    [U, S, V] = svd(E);
    if det(U) < 0
        U = U * [1, 0, 0;
                0, 1, 0;
                0, 0, -1
                ];
    end
    if det(V) < 0
        V = V * [1, 0, 0;
                0, 1, 0;
                0, 0, -1
                ];
    end
    R_zp=[ 0,-1, 0;
           1, 0, 0;
           0, 0, 1];
    R_zm=[ 0, 1, 0;
          -1, 0, 0;
           0, 0, 1];
    R1=U*R_zp'*V';
    R2=U*R_zm'*V';
    T1=inverse_hat_operator(U*R_zp*S*U');
    T2=inverse_hat_operator(U*R_zm*S*U');
end

function [x] = inverse_hat_operator(x_hat)
    x=[x_hat(3,2);
       x_hat(1,3);
       x_hat(2,1)];
end
%% 4.2
function [T_cell, R_cell, d_cell, x1, x2] = reconstruction(T1, T2, R1, R2, correspondences, K)
    % Preparation
    x1 = K\[correspondences(1:2,:);ones(1,size(correspondences,2))];
    x2 = K\[correspondences(3:4,:);ones(1,size(correspondences,2))];

    T_cell={T1,T2,T1,T2};
    R_cell={R1,R1,R2,R2};
    
    d_cell = cell(1, 4); % Initialize a cell array with four cells

    for i = 1:4
        d_cell{i} = zeros(size(correspondences,2), 2); % Assign a 6x2 matrix filled with zeros to each cell
    end
end

%% 4.3
function [T, R, lambda, M1, M2] = reconstruction(T1, T2, R1, R2, correspondences, K)
    % Preparation from task 4.2
    % T_cell    cell array with T1 and T2 
    % R_cell    cell array with R1 and R2
    % d_cell    cell array for the depth information
    % x1        homogeneous calibrated coordinates
    % x2        homogeneous calibrated coordinates
    preparation
    
    % Reconstruction
    max_pos_lambdas=0;
    for i = 1 : 4
        M1 = cross(x2,R_cell{i}*x1);
        cell_vec=mat2cell(M1,3,ones(size(correspondences,2),1));
        M1=[blkdiag(cell_vec{:}),reshape(cross(x2,T_cell{i}*ones(1,size(correspondences,2))),size(correspondences,2)*3,1)];
        [~,~,V]=svd(M1);
        lambdas_temp = V(:,end)/V(end,end);
        
        M2 = cross(x1,R_cell{i}'*x2);
        cell_vec=mat2cell(M2,3,ones(size(correspondences,2),1));
        M2=[blkdiag(cell_vec{:}),reshape(cross(x1,-R_cell{i}'*T_cell{i}*ones(1,size(correspondences,2))),size(correspondences,2)*3,1)];
        [~,~,V]=svd(M2);
        lambdas_temp=[lambdas_temp,V(:,end)/V(end,end)];
        if (sum(sum(lambdas_temp(1:end-1,:)>0)) > max_pos_lambdas)
            max_pos_lambdas=sum(sum(lambdas_temp(1:end-1,:)>0));
            lambda=lambdas_temp(1:end-1,:);
            R=R_cell{i};
            T=lambdas_temp(end,1)*T_cell{i};
        end
end

%% 4.4 
function [T, R, lambda, P1, camC1, camC2] = reconstruction(T1, T2, R1, R2, correspondences, K)
    % This function estimates the depth information and thereby determines the 
    % correct Euclidean movement R and T. Additionally it returns the
    % world coordinates of the image points regarding image 1 and their depth information.
    
    % Preparation from task 4.2
    % T_cell    cell array with T1 and T2 
    % R_cell    cell array with R1 and R2
    % d_cell    cell array for the depth information
    % x1        homogeneous calibrated coordinates
    % x2        homogeneous calibrated coordinates
    preparation
    
    % R, T and lambda from task 4.3
    % T         reconstructed translation
    % R         reconstructed rotation
    % lambda    depth information
    R_T_lambda
    
    % Calculation and visualization of the 3D points and the cameras
    P1 = (ones(3,1) * lambda(:,1)').*x1;
    figure;    
    scatter3(P1(1,:), P1(2,:), P1(3,:), 'filled');
    hold on;
    text(P1(1,:), P1(2,:), P1(3,:), num2str((1:size(P1,2))'), 'FontSize', 12);
    
    camC1 = [-0.2 0.2 0.2 -0.2; 0.2 0.2 -0.2 -0.2; 1 1 1 1];
    camC2 = inv(R) * (camC1 - [T, T, T, T]);
    
    plot3(camC1(1,:), camC1(2,:), camC1(3,:), 'b', 'LineWidth', 2);
    plot3(camC2(1,:), camC2(2,:), camC2(3,:), 'r', 'LineWidth', 2);
    
    text(camC1(1,:), camC1(2,:), camC1(3,:), "Cam1", 'Color', 'blue', 'FontSize', 12, 'FontWeight', 'bold');
    text(camC2(1,:), camC2(2,:), camC2(3,:), "Cam2", 'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold');
    
    campos([43, -22, 87]);
    camup([0, -1, 0]);
    
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on
end

%% 4.5
function [repro_error, x2_repro] = backprojection(correspondences, P1, Image2, T, R, K)
    % This function calculates the mean error of the back projection
    % of the world coordinates P1 from image 1 in camera frame 2
    % and visualizes the correct feature coordinates as well as the back projected ones.
    x2 = [correspondences(3:4 , :) ; ones(1,size(correspondences,2))];
    
    P1_hom = [P1 ; ones(1, size(correspondences,2))];
    
    x2_repro = K * [R,T] * P1_hom;
    
    x2_repro = x2_repro ./ (ones(3,1) * x2_repro(3,:));
    
    repro_error = sum(sqrt(sum((x2_repro - x2).^2,1))) / size(x2,2);
    
    figure('name', 'BAckprojection to second camera frame');
    
    imshow(uint8(Image2))
    hold on
    plot(x2(1,:) , x2(2,:) , 'r*')
    plot(x2_repro(1,:) , x2_repro(2,:) , 'b*')
    for i=1 : size(x2,2)
        hold on 
        x = [x2(1,i), x2_repro(1,i)];
        y = [x2(2,i), x2_repro(2,i)];
        line(x,y);
        text(x2(1,i), x2(2,i), sprintf('Corr %d', i), 'Color', 'red');
        text(x2_repro(1,i), x2_repro(2,i), sprintf('Backproj %d', i), 'Color', 'blue');
    end
    hold off
end