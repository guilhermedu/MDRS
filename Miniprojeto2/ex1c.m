clear all
close all
clc

% Load input data
load('InputDataProject2.mat');

% Constants
v = 2e5; % Speed of light in fiber (km/s)
D = L / v; % Propagation delay matrix (in seconds)

% Parameters
nNodes = size(L, 1); % Number of nodes
nFlows = size(T, 1); % Number of flows
combinations = nchoosek(1:nNodes, 2); % All possible combinations of 2 nodes

% Initialize variables to track the best solution
bestLoad = inf;
bestNodes = [];
bestAverageDelays = zeros(1, 3);

% Iterate over all combinations of anycast nodes
for c = 1:size(combinations, 1)
    anycastNodes = combinations(c, :);
    shortestPaths = cell(1, nFlows);
    roundTripDelays = zeros(1, nFlows);
    
    for f = 1:nFlows
        src = T(f, 2);
        dst = T(f, 3);
        service = T(f, 1);
        
        if service == 3 % Anycast service
            % Find the closest anycast node
            minDelay = inf;
            bestPath = [];
            for acNode = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, src, acNode, 1);
                if totalCost < minDelay
                    minDelay = totalCost;
                    bestPath = shortestPath{1};
                end
            end
            shortestPaths{f} = {bestPath};
            roundTripDelays(f) = minDelay * 2;
        else
            % Unicast services
            [shortestPath, totalCost] = kShortestPath(D, src, dst, 1);
            shortestPaths{f} = {shortestPath{1}};
            roundTripDelays(f) = totalCost * 2;
        end
    end
    
    % Calculate link loads
    Solution = ones(1, nFlows);
    Loads = calculateLinkLoads(nNodes, Links, T, shortestPaths, Solution);
    currentWorstLoad = max(max(Loads(:, 3:4)));
    
    % Update the best solution
    if currentWorstLoad < bestLoad
        bestLoad = currentWorstLoad;
        bestNodes = anycastNodes;
        bestAverageDelays(1) = mean(roundTripDelays(T(:, 1) == 1)); % Service 1
        bestAverageDelays(2) = mean(roundTripDelays(T(:, 1) == 2)); % Service 2
        bestAverageDelays(3) = mean(roundTripDelays(T(:, 1) == 3)); % Service 3
    end
end

% Display results
fprintf('\n============================\n');
fprintf('Best Anycast Nodes: %d and %d\n', bestNodes(1), bestNodes(2));
fprintf('Worst Link Load: %.2f Gbps\n', bestLoad);
fprintf('Average Round-Trip Delays (ms):\n');
fprintf('  Service 1: %.2f ms\n', bestAverageDelays(1) * 1e3);
fprintf('  Service 2: %.2f ms\n', bestAverageDelays(2) * 1e3);
fprintf('  Service 3: %.2f ms\n', bestAverageDelays(3) * 1e3);
fprintf('============================\n');
