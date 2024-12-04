clear all
close all
clc

% Load input data
load('InputDataProject2.mat');

% Constants
v = 2e5; % Speed of light in fiber (km/s)

% Calculate propagation delay matrix (in seconds)
D = L / v;

% Convert to milliseconds
D_ms = D * 1e3;

% Parameters
nNodes = size(L, 1); % Number of nodes
nFlows = size(T, 1); % Number of flows

% Define anycast nodes for service 3
anycastNodes = [3, 10];

% Initialize round-trip delays
roundTripDelays = zeros(1, nFlows);

% Loop through each flow
for f = 1:nFlows
    src = T(f, 2);
    dst = T(f, 3);
    service = T(f, 1);

    if service == 3 % Anycast service
        % Find closest anycast node
        minDelay = inf;
        bestPath = [];
        for acNode = anycastNodes
            [shortestPath, totalCost] = kShortestPath(D_ms, src, acNode, 1);
            if totalCost < minDelay
                minDelay = totalCost;
                bestPath = shortestPath{1};
            end
        end
        % Calculate round-trip delay for the best path
        roundTripDelays(f) = minDelay * 2;
    else
        % Unicast services
        [shortestPath, totalCost] = kShortestPath(D_ms, src, dst, 1);
        roundTripDelays(f) = totalCost * 2; % Round-trip delay
    end
end

% Compute average and worst round-trip delays for each service
services = unique(T(:, 1));
results = zeros(length(services), 2); % Columns: [average, worst]

for s = services'
    serviceDelays = roundTripDelays(T(:, 1) == s);
    results(s, 1) = mean(serviceDelays); % Average
    results(s, 2) = max(serviceDelays);  % Worst
end

% Display results
for s = services'
    fprintf('Service %d:\n', s);
    fprintf('  Average Round-Trip Delay: %.2f ms\n', results(s, 1));
    fprintf('  Worst Round-Trip Delay: %.2f ms\n', results(s, 2));
end

