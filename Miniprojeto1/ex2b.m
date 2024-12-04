% Parameters
lambda = 1500;            % Packet arrival rate (pps)
C = 10;                   % Link bandwidth (Mbps)
f = 1000000;              % Queue size (Bytes)
P = 100000;               % Stopping criterion (number of packets)
b = 10^-5;                % Bit error rate
n_values = [10, 20, 30, 40]; % Number of VoIP flows
alfa = 0.1;               % 90% confidence interval
N = 20;                   % Number of simulation runs

% Initialize variables to store results
PLD_mean = zeros(1, length(n_values)); % Data packet loss
PLV_mean = zeros(1, length(n_values)); % VoIP packet loss
PLD_term = zeros(1, length(n_values)); % Confidence interval for data packet loss
PLV_term = zeros(1, length(n_values)); % Confidence interval for VoIP packet loss

% Loop over different numbers of VoIP flows
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulating for n = ', num2str(n), ' VoIP flows']);
    
    % Initialize arrays to store results from each run
    PLD = zeros(1, N); % Data packet loss
    PLV = zeros(1, N); % VoIP packet loss
    
    % Run the simulation N times
    for j = 1:N
        [PLD(j), PLV(j), ~, ~, ~, ~, ~] = Sim3A(lambda, C, f, P, n, b);
    end
    
    % Calculate mean and confidence intervals for each metric
    PLD_mean(i) = mean(PLD);
    PLD_term(i) = norminv(1 - alfa/2) * sqrt(var(PLD) / N);
    
    PLV_mean(i) = mean(PLV);
    PLV_term(i) = norminv(1 - alfa/2) * sqrt(var(PLV) / N);
    
    % Display results for the current n
    fprintf('\nResults for n = %d VoIP flows:\n', n);
    fprintf('PLD  (Data Loss): %.2e +- %.2e\n', PLD_mean(i), PLD_term(i));
    fprintf('PLV  (VoIP Loss): %.2e +- %.2e\n', PLV_mean(i), PLV_term(i));
end

% Plot packet loss (PLD and PLV)
figure;

% Plot for Data Packet Loss (PLD)
subplot(1, 2, 1);
bar(n_values, PLD_mean);
hold on;
er = errorbar(n_values, PLD_mean, PLD_term, PLD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Packet Loss (%) - Data');
title('Data Packet Loss');
grid on;

% Plot for VoIP Packet Loss (PLV)
subplot(1, 2, 2);
bar(n_values, PLV_mean);
hold on;
er = errorbar(n_values, PLV_mean, PLV_term, PLV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows (n)');
ylabel('Packet Loss (%) - VoIP');
title('VoIP Packet Loss');
grid on;