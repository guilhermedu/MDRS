% Parameter definition
lambda = 1500;            % Packet arrival rate (packets per second)
C = 10;                   % Link bandwidth (Mbps)
f = 1000000;              % Queue size (Bytes)
P = 100000;               % Stopping criterion (number of packets)
b = 10^-5;                % Bit error rate (BER)
n_values = [10, 20, 30, 40]; % Number of VoIP flows (n)
alfa = 0.1;               % 90% confidence interval
N = 20;                   % Number of simulation runs for each n

% Initialize variables to store results
APDD_mean = zeros(1, length(n_values)); % Average packet delay for data packets
APDV_mean = zeros(1, length(n_values)); % Average packet delay for VoIP packets
APDD_term = zeros(1, length(n_values)); % Confidence interval for average delay of data packets
APDV_term = zeros(1, length(n_values)); % Confidence interval for average delay of VoIP packets

% Loop over the different numbers of VoIP flows
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulating for n = ', num2str(n), ' VoIP flows\n']);
    
    % Initialize arrays to store results for each simulation run
    APDD = zeros(1, N); % Average packet delay for data packets
    APDV = zeros(1, N); % Average packet delay for VoIP packets
    
    % Loop to run the simulation 20 times
    for j = 1:N
        [~, ~, APDD(j), APDV(j), ~, ~, ~] = Sim3A(lambda, C, f, P, n, b);
    end
    
    % Calculate the mean and confidence intervals for each parameter
    APDD_mean(i) = mean(APDD);
    APDD_term(i) = norminv(1 - alfa/2) * sqrt(var(APDD) / N);
    
    APDV_mean(i) = mean(APDV);
    APDV_term(i) = norminv(1 - alfa/2) * sqrt(var(APDV) / N);
    
    % Print the results after each simulation for each n
    fprintf('\nResults for n = %d VoIP flows:\n', n);
    fprintf('APDD (Avg Delay Data): %.2e +- %.2e ms\n', APDD_mean(i), APDD_term(i));
    fprintf('APDV (Avg Delay VoIP): %.2e +- %.2e ms\n', APDV_mean(i), APDV_term(i));
end

% Bar plots for average delay (APDD and APDV)
figure;

% Plot for Average Packet Delay (Data)
subplot(1, 2, 1);
bar(n_values, APDD_mean);
hold on;
er = errorbar(n_values, APDD_mean, APDD_term, APDD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Average Delay (ms) - Data');
title('Average Packet Delay (Data)');
grid on;

% Plot for Average Packet Delay (VoIP)
subplot(1, 2, 2);
bar(n_values, APDV_mean);
hold on;
er = errorbar(n_values, APDV_mean, APDV_term, APDV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Average Delay (ms) - VoIP');
title('Average Packet Delay (VoIP)');
grid on;