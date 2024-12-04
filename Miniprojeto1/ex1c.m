% Define the probabilities for predefined packet sizes (64, 110, 1518)
packet_probs = [0.19, 0.23, 0.17]; 
packet_sizes = [64, 110, 1518];

% Equal probability for Data Packets with sizes between 65-109 and 111-1517 bytes
prob_left = (1 - sum(packet_probs)) / ((109 - 65 + 1) + (1517 - 111 + 1));

% Define the possible sizes for the remaining packets (65-109, 111-1517)
remaining_sizes = [65:109, 111:1517];
remaining_prob = prob_left * ones(1, length(remaining_sizes)); % Equal probability for these packet sizes

% Combine all packet sizes and their corresponding probabilities
all_sizes = [packet_sizes, remaining_sizes];
all_probs = [packet_probs, remaining_prob];

% Define BER values to test
ber_values = [1e-6, 1e-4];

% Initialize the packet loss array
ploss_ber = zeros(1, length(ber_values));

% Loop through each BER value to compute the theoretical packet loss
for i = 1:length(ber_values)
    ber = ber_values(i);
    
    % Compute packet loss for each size
    packet_loss_prob = 1 - (1 - ber).^(all_sizes * 8); % Probability of at least one bit error
    
    % Compute weighted sum of packet loss probabilities
    ploss_ber(i) = sum(packet_loss_prob .* all_probs);
end

% Convert the results to percentages
ploss_ber = ploss_ber * 100;

% Display the results
fprintf('Considering bit error rate as the sole cause of packet loss, the theoretical packet loss (%%)\n');
for i = 1:length(ber_values)
    fprintf('For BER = %.1e: %.4f %%\n', ber_values(i), ploss_ber(i));
end
