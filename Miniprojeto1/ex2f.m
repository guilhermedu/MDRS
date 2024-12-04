% General Parameters
lambda_data = 1500;              % Packet arrival rate for data (pps)
C = 10;                          % Link bandwidth (Mbps)
n_values = [10, 20, 30, 40];     % Different numbers of VoIP flows
pps_voip = 50;                   % Packet arrival rate for VoIP per flow (pps)
ber = 1e-5;                      % Bit Error Rate (BER)

% Average size of VoIP packets (110 to 130 bytes)
mean_voip_size = mean(110:130);  % Equal probability for all VoIP packet sizes

% Possible data packet sizes (65:109, 111:1517 bytes)
prob_left = (1 - (0.19 + 0.23 + 0.17)) / ((109 - 65 + 1) + (1517 - 111 + 1));

% Weighted average size of data packets
mean_data_size = 0.19 * 64 + 0.23 * 110 + 0.17 * 1518 + ...
    sum((65:109) * prob_left) + sum((111:1517) * prob_left);

% Probability of successful transmission (without errors) for a packet of size S bits
% P(success) = (1 - BER)^(packet_size_in_bits)
P_success_data = (1 - ber)^(mean_data_size * 8);      % for data packets
P_success_voip = (1 - ber)^(mean_voip_size * 8);      % for VoIP packets

% Initialize vectors to store results
throughput_data_mean = zeros(1, length(n_values));
throughput_voip_mean = zeros(1, length(n_values));
throughput_total_mean = zeros(1, length(n_values));

% Loop to calculate theoretical throughput for each value of n
for i = 1:length(n_values)
    n = n_values(i);  % Number of VoIP flows
    
    % Effective Throughput for data packets
    throughput_data = lambda_data * mean_data_size * 8 / 10^6 * P_success_data;  % Convert to Mbps
    
    % Effective Throughput for VoIP packets
    throughput_voip = n * pps_voip * mean_voip_size * 8 / 10^6 * P_success_voip;  % Convert to Mbps
    
    % Total throughput calculation
    total_throughput = throughput_data + throughput_voip;
    
    % Store results for the bar chart
    throughput_data_mean(i) = throughput_data;
    throughput_voip_mean(i) = throughput_voip;
    throughput_total_mean(i) = total_throughput;
    
    % Display the results
    fprintf('\nTheoretical Results with BER for n = %d VoIP flows:\n', n);
    fprintf('  Theoretical Throughput (Data) = %.2f Mbps\n', throughput_data);
    fprintf('  Theoretical Throughput (VoIP) = %.2f Mbps\n', throughput_voip);
    fprintf('  Total Theoretical Throughput = %.2f Mbps\n', total_throughput);
end

% Generate bar chart for total theoretical throughput
figure;
bar(n_values, throughput_total_mean);
hold on;

% Customize the chart
xlabel('Number of VoIP Flows (n)');
ylabel('Total Theoretical Throughput (Mbps)');
title('Total Theoretical Throughput with BER (Data + VoIP)');
grid on;
hold off;

% Display the chart
fprintf('Bar chart displayed for total theoretical throughput considering BER.\n');
