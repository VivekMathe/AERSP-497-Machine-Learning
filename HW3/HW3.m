%% Load and format data
load("data.mat");
X = a;
Y = da;

% Split train/test as done in HW1
m = size(X,1);
rowSplit = floor(0.7*m);
mixed_row = randperm(m);
trainIdx = mixed_row(1:rowSplit);
testIdx  = mixed_row(rowSplit+1:end);

X_train = X(trainIdx,:);
Y_train = Y(trainIdx,:);
X_test  = X(testIdx,:);
Y_test  = Y(testIdx,:);

%% Feature engineering (same as HW1)
x = X_train(:,1); 
y = X_train(:,2); 
z = X_train(:,3);
Features_raw = [x, y, z, x.*y, x.*z, y.*z, x.^2, y.^2, z.^2];

% min–max scaling
fmin = min(Features_raw,[],1);
fmax = max(Features_raw,[],1);
X_train_scaled = (Features_raw - fmin) ./ (fmax - fmin);

% Test set scaling
xt = X_test(:,1); yt = X_test(:,2); zt = X_test(:,3);
Features_raw_test = [xt, yt, zt, xt.*yt, xt.*zt, yt.*zt, xt.^2, yt.^2, zt.^2];
X_test_scaled = (Features_raw_test - fmin) ./ (fmax - fmin);

%% Neural Network Setup
input_dim = size(X_train_scaled,2);
hidden_dim = 55;   % number of hidden neurons
output_dim = size(Y_train,2);

W1 = randn(input_dim, hidden_dim) * 0.1; % input → hidden
b1 = zeros(1, hidden_dim);
W2 = randn(hidden_dim, output_dim) * 0.1; % hidden → output
b2 = zeros(1, output_dim);

%% Training parameters
alpha = 0.05;    
epochs = 1000;
m_train = size(X_train_scaled,1);
loss_history = zeros(epochs,1);

%% Sigmoid function
sigmoid = @(z) 1 ./ (1 + exp(-z));

%% Training Loop
for epoch = 1:epochs
    % --- Forward pass ---
    Z1 = X_train_scaled*W1 + b1;
    A1 = sigmoid(Z1);                
    Z2 = A1*W2 + b2;
    Y_hat = Z2;
    
    % Mean squared error loss calculation
    loss = mean(sum((Y_hat - Y_train).^2,2));
    loss_history(epoch) = loss;
    
    dZ2 = (Y_hat - Y_train) / m_train; % output layer error
    dW2 = A1' * dZ2;
    db2 = sum(dZ2,1);
    
    dA1 = dZ2 * W2';
    dZ1 = dA1 .* (A1 .* (1 - A1)); % Derivative of sigmoid function
    dW1 = X_train_scaled' * dZ1;
    db1 = sum(dZ1,1);
    
    % Updating weights
    W1 = W1 - alpha * dW1;
    b1 = b1 - alpha * db1;
    W2 = W2 - alpha * dW2;
    b2 = b2 - alpha * db2;
end


%% Evaluate on test set
Z1t = X_test_scaled*W1 + b1;
A1t = sigmoid(Z1t);
Z2t = A1t*W2 + b2;
Y_pred = Z2t;

test_error = (norm(Y_pred - Y_test)/norm(Y_test)) * 100;
fprintf('Test error = %.3f %%\n', test_error);

%% Plot training loss
figure;
plot(loss_history,'LineWidth',1.5);
xlabel('Epoch'); ylabel('Loss (MSE)');
title('Training Loss');
grid on;