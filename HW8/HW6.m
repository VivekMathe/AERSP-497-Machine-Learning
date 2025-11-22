x1 = x1(:);
x2 = x2(:);
N = length(x1);

%% 1. Visualize data and manually pick "rare events"
% We use a scatter plot to visualize the 2D feature space.
% Rare events will be points far away from the dense central cluster.

figure('Name', 'Q1: Visualizing Data');
scatter(x1, x2, 'filled');
xlabel('Energy x1');
ylabel('Energy x2');
title('Scatter Plot of Turbulent Eddy Energies');
grid on;
hold on;

mu1 = mean(x1); sigma1 = std(x1);
mu2 = mean(x2); sigma2 = std(x2);

figure('Name', 'Q2: Gaussian Approximation Check');

% Subplot for x1
subplot(2,1,1);
histogram(x1, 30, 'Normalization', 'pdf'); hold on;
x_range1 = linspace(min(x1), max(x1), 100);
y_gauss1 = normpdf(x_range1, mu1, sigma1);
plot(x_range1, y_gauss1, 'r-', 'LineWidth', 2);
title('PDF of x1 vs Gaussian Fit');
legend('Data Hist', 'Gaussian Fit');

% Subplot for x2
subplot(2,1,2);
histogram(x2, 30, 'Normalization', 'pdf'); hold on;
x_range2 = linspace(min(x2), max(x2), 100);
y_gauss2 = normpdf(x_range2, mu2, sigma2);
plot(x_range2, y_gauss2, 'r-', 'LineWidth', 2);
title('PDF of x2 vs Gaussian Fit');
legend('Data Hist', 'Gaussian Fit');

%% 3. Check for Statistical Independence
% We calculate the Linear Correlation Coefficient (Pearson's rho).
% If rho is close to 0, they are uncorrelated. 
% (Note: Since data is non-Gaussian, uncorrelated doesn't strictly mean independent, 
% but for this HW, rho ~ 0 usually justifies the assumption).

corr_matrix = corrcoef(x1, x2);
rho = corr_matrix(1,2);

fprintf('------------------------------------------------\n');
fprintf('Correlation Coefficient (rho): %.4f\n', rho);
if abs(rho) < 0.1
    disp('Correlation is low. We will treat them as independent.');
else
    disp('Correlation is significant. Independence assumption is weak.');
end
fprintf('------------------------------------------------\n');

%% 4. Rare Events vs Epsilon
% We assume Independence: P(x1, x2) = P(x1) * P(x2)
% We use the Gaussian formulas from Q2 to estimate P.

% 1. Calculate Probability Density for every point
p_x1 = normpdf(x1, mu1, sigma1);
p_x2 = normpdf(x2, mu2, sigma2);
p_joint = p_x1 .* p_x2; % Joint Probability

% 2. Sweep Epsilon
% Epsilon is our threshold. If P_joint < epsilon, it's a "rare event".
% We sweep from 0 to the maximum density found in the cluster.
max_p = max(p_joint);
epsilon_values = linspace(0, max_p, 100000); 
rare_counts = zeros(size(epsilon_values));

for i = 1:length(epsilon_values)
    eps_thresh = epsilon_values(i);
    % Count how many points are BELOW this probability threshold
    rare_counts(i) = sum(p_joint < eps_thresh);
end

% 3. Plot the result
figure('Name', 'Q4: Rare Events vs Epsilon');
plot(epsilon_values, rare_counts, 'b-', 'LineWidth', 2);
xlabel('Threshold Epsilon (\epsilon)');
ylabel('Number of Rare Events detected');
title('Count of Rare Events as function of \epsilon');
grid on;
xlim([0 max_p]);
ylim([0 N]);

% Optional: Visualization of the thresholding (Rubric Point 1)
% Let's pick an epsilon that selects roughly 10 anomalies to show what it does
% [~, idx] = min(abs(rare_counts - 7)); % Find eps for ~10 events
% demo_eps = epsilon_values(idx);
% anomalies = p_joint < demo_eps;
% 
% figure('Name', 'Q4 Visualization: Selected Anomalies');
% scatter(x1, x2, 'MarkerEdgeColor', [0.7 0.7 0.7]); hold on; % Grey normal points
% scatter(x1(anomalies), x2(anomalies), 'r', 'filled'); % Red anomalies
% legend('Normal Flow', ['Rare Events (\epsilon = ' num2str(demo_eps, '%.3f') ')']);
% xlabel('x1'); ylabel('x2');
% title('Visualizing the detected Rare Events');
% grid on;

target_count = 8;

% 1. Sort all probability scores from smallest (rare) to largest (normal)
sorted_p = sort(p_joint);

% 2. Pick the probability of the Nth point exactly
% We add a tiny "fudge factor" (eps) to make sure we include that point
demo_eps = sorted_p(target_count) + eps; 

% 3. Apply
anomalies = p_joint < demo_eps;
actual_count = sum(anomalies);

figure('Name', 'Q4: Exact Count Visualization');
scatter(x1, x2, 'MarkerEdgeColor', [0.7 0.7 0.7]); hold on;
scatter(x1(anomalies), x2(anomalies), 'r', 'filled');
legend('Normal Flow', ['Rare Events (Count = ' num2str(actual_count) ')']);
xlabel('x1'); ylabel('x2');
title(['Visualizing the Rarest ' num2str(actual_count) ' Anomalies']);
grid on;