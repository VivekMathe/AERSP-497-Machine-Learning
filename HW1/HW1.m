%HW#1
%mutivariate linear regression to extract dynamics
%% preamble
close all;
clear all;
clc;

set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultAxesFontSize',14);
set(0,'DefaultTextFontSize',14);
set(0,'defaulttextinterpreter','latex');
set(0,'defaultAxesTickLabelInterpreter','latex');
set(0,'defaultLegendInterpreter','latex');
set(0, 'defaultLineLinewidth', 1);

%% load data. If required, add some Gaussian noise to the data
load("data.mat")


%% format the data into input features and target variables
X = a;
Y = da;
%% visualize the data 
plot3(X(:,1), X(:,2), X(:,3))
xlabel('x data'); ylabel('y data'); zlabel('z data'); grid on

%% Partition the data into training data and test data 
%% recommendation: a random partition is recommended
%% recommendation: partition 70% data for training and 30% data for testing

m = size(a,1);
rowSplit = floor(0.7 * m);  % Finding 70 percent of given set size

mixed_row = randperm(m);  % Randomly mixing row indices

trainIndices = mixed_row(1:rowSplit);
testIndices  = mixed_row(rowSplit+1:end);

% Training data
X_train = X(trainIndices,:);  % First 70% taken as training indices
Y_train = Y(trainIndices,:);

% Test data
X_test  = X(testIndices,:);  % Remaining 30% taken as testing indices
Y_test  = Y(testIndices,:);

%% Implement Gradient Descent 

x = X_train(:,1); y = X_train(:,2); z = X_train(:,3);

Features_raw = [x, y, z, x.*y, x.*z, y.*z, x.^2, y.^2, z.^2];

fmin = min(Features_raw,[],1);  % Returns row of minimums
fmax = max(Features_raw,[],1);  % Returns row of maximums

Features_scaled = (Features_raw - fmin) ./ (fmax - fmin);
Features = [ones(numel(trainIndices), 1), Features_scaled];

n = 10;
alpha = 0.05;
Theta_old = zeros(n, 3);  % n includes bias a0;
load tht_data.mat

eps = 0.00001;

while(norm(Theta_old-Theta)>eps)
    Theta_old = Theta;
    grad = (1/numel(trainIndices)) * (Features' * (Features*Theta - Y_train));
    Theta = Theta_old - alpha * grad;
end

%use mvregress to directly get the coefficient
B = zeros(size(Features, 2), size(Y_train, 2));  % 10 x 3 matrix
for i = 1:size(Y_train, 2)
    B(:, i) = mvregress(Features, Y_train(:, i), 'maxiter', 10000);
end

%% Compare Linear Regression and mvregress results to training data

x_test = X_test(:,1);
y_test = X_test(:,2);
z_test = X_test(:,3);

% Build raw features (same as training)
Features_raw_test = [x_test, y_test, z_test, x_test.*y_test, x_test.*z_test, y_test.*z_test, ...
                     x_test.^2, y_test.^2, z_test.^2];

% Apply the SAME min–max scaling (use fmin,fmax from training!)
Features_scaled_test = (Features_raw_test - fmin) ./ (fmax - fmin);

% Add bias column
Features_test = [ones(size(Features_scaled_test,1),1), Features_scaled_test];

% Predictions
Y_pred = Features_test * Theta;

% Compute error metrics
errors = Y_pred - Y_test;            
percent_error = (norm(errors) / norm(Y_test)) * 100;
fprintf('Manual Regression Overall error = %.3f %%\n', percent_error);

Y_Matlabpred = Features_test * B;

Mat_errors = Y_Matlabpred - Y_test;
percentMat_error = (norm(Mat_errors)/norm(Y_test))*100;
fprintf('Matlab Overall error = %.3f %%\n', percentMat_error);