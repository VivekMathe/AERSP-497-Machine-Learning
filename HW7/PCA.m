%% HW 7 - PCA of 3D Fields (Report Generation Script)
close all; clear; clc;

% 1. Load Data
filename = 'near_wall_channel_data.h5';
try
    vel = h5read(filename,'/Velocity_0001');
    x = h5read(filename,'/xcoor');
    y = h5read(filename,'/ycoor');
    z = h5read(filename,'/zcoor');
catch
    error('File not found.');
end

% Extract u (streamwise velocity)
u = squeeze(vel(1,:,:,:)); 
[Nx, Ny, Nz] = size(u);

% 2. Prepare Data (Method of Snapshots)
% Reshape: Rows = Spatial (y,z), Cols = Snapshots (x)
u_perm = permute(u, [2, 3, 1]); 
D = reshape(u_perm, Ny*Nz, Nx); 

% Calculate Mean and Fluctuations
u_mean_field = mean(D, 2);
D_fluc = D - u_mean_field;

% --- FIGURE 1: Mean Flow Visualization (Context) ---
figure('Position',[100, 100, 1000, 300]);
mean_grid = reshape(u_mean_field, Ny, Nz);
contourf(z, y, mean_grid, 20, 'LineStyle', 'none');
colormap('parula'); colorbar;
title('Figure 1: Mean Streamwise Velocity Profile');
xlabel('z (Spanwise location)'); ylabel('y (Distance from wall)');
axis tight; 
% Save for Report
exportgraphics(gcf, 'MeanFlow.png', 'Resolution', 300);

% 3. Compute PCA (Method of Snapshots)
% We use D' * D (Nx x Nx) because (Ny*Nz) is too big (300 million+)
C_snap = (D_fluc' * D_fluc) / Nx; 
[V_snap, Lambda] = eig(C_snap, 'vector');
[lambda_sorted, idx] = sort(Lambda, 'descend');
V_snap = V_snap(:, idx);

% Reconstruct Spatial Modes
Phi = D_fluc * V_snap * diag(1./sqrt(lambda_sorted * Nx));

% 4. Energy Analysis
total_energy = sum(lambda_sorted);
energy_cumulative = cumsum(lambda_sorted) / total_energy;
k99 = find(energy_cumulative >= 0.99, 1);

% --- FIGURE 2: Energy Spectrum ---
figure('Position',[100, 100, 800, 600]);
subplot(2,1,1);
plot(lambda_sorted/total_energy, 'o-', 'LineWidth', 1, 'MarkerSize', 4);
title('Normalized Eigenvalue Spectrum'); ylabel('Energy Fraction'); grid on; xlim([0 50]);
subplot(2,1,2);
plot(energy_cumulative, 'r-', 'LineWidth', 2);
yline(0.99, 'k--', ['99% Cutoff (' num2str(k99) ' modes)'], 'LabelHorizontalAlignment','right');
title('Cumulative Energy'); xlabel('Mode Number'); ylabel('Cumulative Sum'); grid on;
% Save for Report
exportgraphics(gcf, 'EnergySpec.png', 'Resolution', 300);

% 5. Visualize Modes
% --- FIGURE 3: POD Modes ---
figure('Position',[100, 100, 1200, 600]);
colormap('jet');
for i = 1:4
    subplot(4, 1, i); % Stack them vertically to see width
    mode_shape = reshape(Phi(:, i), Ny, Nz);
    
    % Determine max abs value for symmetric color limits
    clim_val = max(abs(mode_shape(:)));
    
    contourf(z, y, mode_shape, 20, 'LineStyle', 'none');
    clim([-clim_val, clim_val]); % Symmetric colors (Blue=Neg, Red=Pos)
    colorbar;
    if i == 4
        xlabel('z (Spanwise)');
    end
    ylabel('y (Wall)');
    title(['POD Mode ' num2str(i)]);
    axis tight; 
    pbaspect([4 1 1]); % Force aspect ratio so it's not too thin
end
% Save for Report
exportgraphics(gcf, 'Modes.png', 'Resolution', 300);

% Display Stats for report writing
fprintf('Stats for Report:\n');
fprintf('Covariance Matrix Size: %d x %d\n', Ny*Nz, Ny*Nz);
fprintf('Number of Elements: %d\n', (Ny*Nz)^2);
fprintf('Modes for 99%%: %d\n', k99);