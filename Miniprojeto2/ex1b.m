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

% Define anycast nodes for service 3
anycastNodes = [3, 10];

% Initialize routing paths for all flows
shortestPaths = cell(1, nFlows);

% Loop through each flow to calculate the shortest paths
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
        % Store as a cell of cells for compatibility
        shortestPaths{f} = {bestPath};
    else
        % Unicast services
        [shortestPath, ~] = kShortestPath(D, src, dst, 1);
        % Store as a cell of cells for compatibility
        shortestPaths{f} = {shortestPath{1}};
    end
end


% Prepare input for calculateLinkLoads
Solution = ones(1, nFlows); % Use the first path for all flows
Loads = calculateLinkLoads(nNodes, Links, T, shortestPaths, Solution);

% Display link loads
fprintf('Link Loads (Gbps):\n');
for i = 1:size(Links, 1)
    fprintf('Link %d-%d: Forward %.2f Gbps, Reverse %.2f Gbps\n', ...
            Loads(i, 1), Loads(i, 2), Loads(i, 3), Loads(i, 4));
end

% Determine the worst link load
worstLoad = max(max(Loads(:, 3:4)));
fprintf('Worst Link Load: %.2f Gbps\n', worstLoad);
