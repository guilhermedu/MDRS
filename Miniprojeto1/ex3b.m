% General Parameters
lambda = 1500;            % Packet arrival rate (pps)
C = 10;                   % Link bandwidth (Mbps)
f = 10000;                % Queue size (Bytes)
P = 100000;               % Stopping criterion (number of packets)
b = 10^-5;                % Bit error rate (BER)
n_values = [10, 20, 30, 40]; % Values of n (VoIP flows)
alfa = 0.1;               % 90% confidence interval
N = 20;                   % Number of runs per n

% Initialize arrays for results
PLD_mean = zeros(1, length(n_values));
PLV_mean = zeros(1, length(n_values));
APDD_mean = zeros(1, length(n_values));
APDV_mean = zeros(1, length(n_values));

PLD_term = zeros(1, length(n_values));
PLV_term = zeros(1, length(n_values));
APDD_term = zeros(1, length(n_values));
APDV_term = zeros(1, length(n_values));

% Loop through different values of VoIP flows
for i = 1:length(n_values)
    n = n_values(i);
    disp(['Simulating for n = ', num2str(n), ' VoIP flows']);
    
    % Initialize temporary arrays for storing run results
    PLD = zeros(1, N);
    PLV = zeros(1, N);
    APDD = zeros(1, N);
    APDV = zeros(1, N);
    
    % Run the simulation N times for each n
    for j = 1:N
        [PLD(j), PLV(j), APDD(j), APDV(j)] = Sim4(lambda, C, f, P, n);
    end
    
    % Calculate means and confidence intervals
    PLD_mean(i) = mean(PLD);
    PLD_term(i) = norminv(1 - alfa/2) * sqrt(var(PLD) / N);
    
    PLV_mean(i) = mean(PLV);
    PLV_term(i) = norminv(1 - alfa/2) * sqrt(var(PLV) / N);
    
    APDD_mean(i) = mean(APDD);
    APDD_term(i) = norminv(1 - alfa/2) * sqrt(var(APDD) / N);
    
    APDV_mean(i) = mean(APDV);
    APDV_term(i) = norminv(1 - alfa/2) * sqrt(var(APDV) / N);
    
    % Display results
    fprintf('\nResults for n = %d VoIP flows:\n', n);
    fprintf('PLD (Data Loss): %.2e +- %.2e\n', PLD_mean(i), PLD_term(i));
    fprintf('PLV (VoIP Loss): %.2e +- %.2e\n', PLV_mean(i), PLV_term(i));
    fprintf('APDD (Avg Delay Data): %.2e +- %.2e ms\n', APDD_mean(i), APDD_term(i));
    fprintf('APDV (Avg Delay VoIP): %.2e +- %.2e ms\n', APDV_mean(i), APDV_term(i));
end

% ----- Figure 1: Packet Loss -----
figure;
subplot(1, 2, 1);
bar(n_values, PLD_mean);
hold on;
er = errorbar(n_values, PLD_mean, PLD_term, PLD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows');
ylabel('Packet Loss (%) - Data');
title('Packet Loss (Data)');
grid on;

subplot(1, 2, 2);
bar(n_values, PLV_mean);
hold on;
er = errorbar(n_values, PLV_mean, PLV_term, PLV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows');
ylabel('Packet Loss (%) - VoIP');
title('Packet Loss (VoIP)');
grid on;

% ----- Figure 2: Average Delay -----
figure;
subplot(1, 2, 1);
bar(n_values, APDD_mean);
hold on;
er = errorbar(n_values, APDD_mean, APDD_term, APDD_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows');
ylabel('Average Delay (ms) - Data');
title('Average Delay (Data)');
grid on;

subplot(1, 2, 2);
bar(n_values, APDV_mean);
hold on;
er = errorbar(n_values, APDV_mean, APDV_term, APDV_term);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off;
xlabel('Number of VoIP Flows');
ylabel('Average Delay (ms) - VoIP');
title('Average Delay (VoIP)');
grid on;
