% Definition of parameters
lambda = 1500;            % Packet arrival rate (pps)
C = 10;                   % Link bandwidth (Mbps)
f = 1000000;              % Queue size (Bytes)
P = 100000;               % Stopping criterion (number of packets)
b = 10^-5;                % Bit error rate
n_values = [10, 20, 30, 40]; % Values of n (VoIP flows)
alfa = 0.1;               % Confidence interval of 90%
N = 20;                   % Number of runs for each n value

% Initialize variables to store throughput results
TT_mean = zeros(1, length(n_values));
TT_term = zeros(1, length(n_values));

% Loop through different numbers of VoIP flows
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulating for n = ', num2str(n), ' VoIP flows']);
    
    % Initialize vectors to store throughput results for each run
    TT = zeros(1, N);
    
    % Loop to run the simulation 20 times
    for j = 1:N
        % Call the Sim3A function to calculate throughput
        [~, ~, ~, ~, ~, ~, TT(j)] = Sim3A(lambda, C, f, P, n, b);
    end
    
    % Calculate the mean and confidence intervals for throughput
    TT_mean(i) = mean(TT);
    TT_term(i) = norminv(1 - alfa/2) * sqrt(var(TT) / N);
    
    % Display throughput values for each n
    fprintf('\nSimulated values for n = %d VoIP flows:\n', n);
    fprintf('TT   (Throughput): %.2e +- %.2e Mbps\n', TT_mean(i), TT_term(i));
end

% Display calculated TT_mean and TT_term values to check variation
disp('Values of TT_mean:');
disp(TT_mean);
disp('Values of TT_term:');
disp(TT_term);

% Plot transmitted throughput (TT)
figure;
bar(n_values, TT_mean);
hold on;

% Add error bars (confidence intervals)
er = errorbar(n_values, TT_mean, TT_term, TT_term);
er.Color = [0 0 0];  % Set error bar color
er.LineStyle = 'none';  % No connecting line for error bars

hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Transmitted Throughput (Mbps)');
title('Transmitted Throughput');
grid on;
