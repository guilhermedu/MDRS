clear all
close all
clc

% Load input data
load('InputDataProject2.mat');

% Constants
v = 2e5; % Speed of light in fiber (km/s)

% Calculate propagation delay matrix (in seconds)
D = L / v;

% Parameters
nNodes = size(L, 1); % Number of nodes
nFlows = size(T, 1); % Number of flows

% Generate all possible combinations of 2 nodes
combinations = nchoosek(1:nNodes, 2);

% Initialize variables to track the best solution
bestWorstDelay = inf;
bestNodes = [];
bestRoundTripDelays = zeros(1, nFlows);
bestAverageDelays = zeros(1, 3);
worstDelays = zeros(1, 3);

% Iterate over all combinations of anycast nodes
for c = 1:size(combinations, 1)
    anycastNodes = combinations(c, :);
    roundTripDelays = zeros(1, nFlows);
    
    for f = 1:nFlows
        src = T(f, 2);
        dst = T(f, 3);
        service = T(f, 1);
        
        if service == 3 % Anycast service
            % Find the closest anycast node
            minDelay = inf;
            for acNode = anycastNodes
                [~, totalCost] = kShortestPath(D, src, acNode, 1);
                if totalCost < minDelay
                    minDelay = totalCost;
                end
            end
            roundTripDelays(f) = minDelay * 2; % Round-trip delay
        else
            % Unicast services
            [~, totalCost] = kShortestPath(D, src, dst, 1);
            roundTripDelays(f) = totalCost * 2; % Round-trip delay
        end
    end
    
    % Evaluate the worst round-trip delay for the anycast service
    currentWorstDelay = max(roundTripDelays(T(:, 1) == 3));
    
    % Update best solution if the current worst delay is better
    if currentWorstDelay < bestWorstDelay
        bestWorstDelay = currentWorstDelay;
        bestNodes = anycastNodes;
        bestRoundTripDelays = roundTripDelays;
        bestAverageDelays(1) = mean(roundTripDelays(T(:, 1) == 1)); % Average for service 1
        bestAverageDelays(2) = mean(roundTripDelays(T(:, 1) == 2)); % Average for service 2
        bestAverageDelays(3) = mean(roundTripDelays(T(:, 1) == 3)); % Average for service 3
        worstDelays(1) = max(roundTripDelays(T(:, 1) == 1));
        worstDelays(2) = max(roundTripDelays(T(:, 1) == 2));
        worstDelays(3) = max(roundTripDelays(T(:, 1) == 3));
    end
end

% Display the results
fprintf('\n============================\n');
fprintf('Best Anycast Nodes: %d and %d\n', bestNodes(1), bestNodes(2));
fprintf('Worst Round-Trip Delay (Anycast Service): %.2f ms\n', bestWorstDelay * 1e3);
fprintf('Average Round-Trip Delays (ms):\n');
fprintf('  Service 1: %.2f ms\n', bestAverageDelays(1) * 1e3);
fprintf('  Service 2: %.2f ms\n', bestAverageDelays(2) * 1e3);
fprintf('  Service 3: %.2f ms\n', bestAverageDelays(3) * 1e3);
fprintf('Worst Round-Trip Delays (ms):\n');
fprintf('  Service 1: %.2f ms\n', worstDelays(1) * 1e3);
fprintf('  Service 2: %.2f ms\n', worstDelays(2) * 1e3);
fprintf('  Service 3: %.2f ms\n', worstDelays(3) * 1e3);
fprintf('============================\n');
