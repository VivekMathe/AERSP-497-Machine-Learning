%% Part 1
load('DragRed.mat')
figure;
plot(h(drag==1), s(drag==1), 'o','DisplayName','Reduced Drag')
hold on
plot(h(drag==0), s(drag==0), 'x','DisplayName','Drag not Reduced')
xlabel('h'); ylabel('s');
legend('show')

%% Part 2
% Written out cost function per 2.
function J = costFunction(m, theta, X, Y)
 hyp = 1./(1+exp(-X*theta));
 J = -(1/m)*sum(Y.*log(hyp) + (1-Y).*log(1-hyp)); % Written out cost function
end

% feature scaling - second order only
X = [h, s, h.^2, h.*s, s.^2];
mu = mean(X);
sigma = std(X);
X_scaled = (X - mu) ./ sigma;
m = length(drag);
X = [ones(m,1) X_scaled];
Y = drag;

%% Part 3
Theta_old = zeros(size(X,2),1);
Theta = ones(size(X,2),1);
alpha = 0.05;
eps = 0.00001;
while(norm(Theta_old-Theta)>eps)
 Theta_old = Theta;
 hyp = 1./(1+exp(-X*Theta_old));
 grad = (1/m)*(X'*(hyp - Y)); % (Partial J)/(Partial Theta)
 Theta = Theta_old - alpha * grad;
end

%% Part 3 fminunc
initial_theta = zeros(size(X,2),1);
options = optimset('MaxIter', 1000, 'MaxFunEvals', 10000, 'TolFun', 1e-6);
theta_fminunc = fminunc(@(t)(costFunction(length(Y), t, X, Y)), initial_theta, options);

%% Part 4
figure;
plot(h(drag==1), s(drag==1), 'o','DisplayName','Reduced Drag')
hold on
plot(h(drag==0), s(drag==0), 'x','DisplayName','Drag not Reduced')

% Define the decision boundary function
f = @(h, s) Theta(1) + ...
                    Theta(2)*((h - mu(1))./sigma(1)) + ...
                    Theta(3)*((s - mu(2))./sigma(2)) + ...
                    Theta(4)*((h.^2 - mu(3))./sigma(3)) + ...
                    Theta(5)*((h.*s - mu(4))./sigma(4)) + ...
                    Theta(6)*((s.^2 - mu(5))./sigma(5));

f_m = @(h, s) theta_fminunc(1) + ...
                    theta_fminunc(2)*((h - mu(1))./sigma(1)) + ...
                    theta_fminunc(3)*((s - mu(2))./sigma(2)) + ...
                    theta_fminunc(4)*((h.^2 - mu(3))./sigma(3)) + ...
                    theta_fminunc(5)*((h.*s - mu(4))./sigma(4)) + ...
                    theta_fminunc(6)*((s.^2 - mu(5))./sigma(5));

% Plot where f = 0
fimplicit(f, [min(h) max(h) min(s) max(s)], 'LineWidth', 2, 'DisplayName', 'Decision Boundary')
fimplicit(f_m, [min(h) max(h) min(s) max(s)], 'LineWidth', 2, 'DisplayName', 'fminunc Boundary')
xlabel('h'); ylabel('s');
legend('show')