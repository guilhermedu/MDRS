% Parameter definition
lambda = 1500;            % Packet arrival rate (packets per second)
C = 10;                   % Link bandwidth (Mbps)
f = 1000000;              % Queue size (Bytes)
P = 100000;               % Stopping criterion (number of packets)
b = 10^-5;                % Bit error rate (BER)
n_values = [10, 20, 30, 40]; % Number of VoIP flows (n)
alfa = 0.1;               % 90% confidence interval
N = 20;                   % Number of simulation runs for each value of n

% Initialize variables to store results
MPDD_mean = zeros(1, length(n_values)); % Maximum packet delay for data packets
MPDV_mean = zeros(1, length(n_values)); % Maximum packet delay for VoIP packets

MPDD_term = zeros(1, length(n_values)); % Confidence interval for maximum packet delay (data)
MPDV_term = zeros(1, length(n_values)); % Confidence interval for maximum packet delay (VoIP)

% Loop through different numbers of VoIP flows
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulating for n = ', num2str(n), ' VoIP flows']);
    
    % Initialize vectors to store results for each simulation run
    MPDD = zeros(1, N); % Maximum packet delay for data
    MPDV = zeros(1, N); % Maximum packet delay for VoIP
    
    % Loop to run the simulation 20 times
    for j = 1:N
        [~, ~, ~, ~, MPDD(j), MPDV(j), ~] = Sim3A(lambda, C, f, P, n, b);
    end
    
    % Calculate the mean and confidence intervals for each parameter
    MPDD_mean(i) = mean(MPDD);
    MPDD_term(i) = norminv(1 - alfa/2) * sqrt(var(MPDD) / N);
    
    MPDV_mean(i) = mean(MPDV);
    MPDV_term(i) = norminv(1 - alfa/2) * sqrt(var(MPDV) / N);
    
    % Display the results after each simulation run for each n
    fprintf('\nResults for n = %d VoIP flows:\n', n);
    fprintf('MPDD (Max Delay Data): %.2e +- %.2e ms\n', MPDD_mean(i), MPDD_term(i));
    fprintf('MPDV (Max Delay VoIP): %.2e +- %.2e ms\n', MPDV_mean(i), MPDV_term(i));
end

% Bar charts for maximum packet delay (MPDD and MPDV)
figure;

% Chart for Maximum Delay (Data)
subplot(1, 2, 1);
bar(n_values, MPDD_mean);
hold on;
er = errorbar(n_values, MPDD_mean, MPDD_term, MPDD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Maximum Delay (ms) - Data');
title('Maximum Packet Delay (Data)');
grid on;

% Chart for Maximum Delay (VoIP)
subplot(1, 2, 2);
bar(n_values, MPDV_mean);
hold on;
er = errorbar(n_values, MPDV_mean, MPDV_term, MPDV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Maximum Delay (ms) - VoIP');
title('Maximum Packet Delay (VoIP)');
grid on;
