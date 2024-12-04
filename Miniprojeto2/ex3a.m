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
nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
nFlows = size(T, 1);
k = 12; % Number of candidate paths/pairs
timeLimit = 60; % Time limit for the algorithm
anycastNodes = [3, 10]; % Fixed anycast nodes for anycast service

% Generate candidate paths/pairs
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);

for f = 1:nFlows
    src = T(f, 2);
    dst = T(f, 3);
    service = T(f, 1);

    if service == 1 % Unicast service s = 1
        [shortestPath, totalCost] = kShortestPath(D, src, dst, k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
    elseif service == 2 % Unicast service s = 2 with 1:1 protection
        [firstPaths, secondPaths, totalPairCosts] = kShortestPathPairs(D, src, dst, k);
        for i = 1:length(totalPairCosts)
            sP{f}{i} = {firstPaths{i}, secondPaths{i}}; % Store pairs as nested cell arrays
        end
        nSP(f) = length(totalPairCosts);
    elseif service == 3 % Anycast service
        % Compute shortest paths to both anycast nodes
        try
            [shortestPath1, totalCost1] = kShortestPath(D, src, anycastNodes(1), k);
        catch
            totalCost1 = [];
        end
        try
            [shortestPath2, totalCost2] = kShortestPath(D, src, anycastNodes(2), k);
        catch
            totalCost2 = [];
        end

        % Validate and select the best path
        if ~isempty(totalCost1) && ~isempty(totalCost2)
            if totalCost1(1) <= totalCost2(1)
                sP{f} = shortestPath1;
                nSP(f) = length(totalCost1);
            else
                sP{f} = shortestPath2;
                nSP(f) = length(totalCost2);
            end
        elseif ~isempty(totalCost1)
            sP{f} = shortestPath1;
            nSP(f) = length(totalCost1);
        elseif ~isempty(totalCost2)
            sP{f} = shortestPath2;
            nSP(f) = length(totalCost2);
        else
            error('No valid paths found for flow %d from node %d to anycast nodes.', f, src);
        end
    end
end

% Expand paths to handle link-disjoint cases
expandedPaths = cell(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 2 % Link-disjoint case
        % Flatten all candidate pairs into individual paths
        tempPaths = {};
        for i = 1:nSP(f)
            tempPaths{end + 1} = sP{f}{i}{1}; % First path in pair
            tempPaths{end + 1} = sP{f}{i}{2}; % Second path in pair
        end
        expandedPaths{f} = tempPaths;
    else
        expandedPaths{f} = sP{f};
    end
end

% Multi Start Hill Climbing algorithm
t = tic;
bestLoad = inf;
contador = 0;
somador = 0;
bestLoadTime = 0;

while toc(t) < timeLimit
    % Greedy randomized start
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, expandedPaths, nSP);

    % Hill climbing optimization
    [sol, load] = HillClimbingStrategy(nNodes, Links, T, expandedPaths, nSP, sol, load);

    % Calculate final link loads
    Loads = calculateLinkLoads(nNodes, Links, T, expandedPaths, sol);
    load = max(max(Loads(:, 3:4))); % Worst link load

    % Update the best solution if the current one is better
    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = Loads;
        bestLoadTime = toc(t);
    end

    % Track performance parameters
    contador = contador + 1;
    somador = somador + load;
end

% Calculate round-trip delays
roundTripDelays = zeros(1, nFlows);
for f = 1:nFlows
    src = T(f, 2);
    dst = T(f, 3);
    service = T(f, 1);

    if service == 3 % Anycast service
        minDelay = inf;
        for acNode = anycastNodes
            try
                [~, totalCost] = kShortestPath(D, src, acNode, 1);
                if totalCost < minDelay
                    minDelay = totalCost;
                end
            catch
            end
        end
        roundTripDelays(f) = minDelay * 2; % Round-trip delay
    else
        try
            [~, totalCost] = kShortestPath(D, src, dst, 1);
            roundTripDelays(f) = totalCost * 2; % Round-trip delay
        catch
        end
    end
end

% Calculate average and worst round-trip delays per service
avgDelays = zeros(1, 3);
worstDelays = zeros(1, 3);
for service = 1:3
    delays = roundTripDelays(T(:, 1) == service);
    avgDelays(service) = mean(delays) * 1e3; % Convert to ms
    worstDelays(service) = max(delays) * 1e3; % Convert to ms
end

% Display results
fprintf('Multi Start Hill Climbing with 1:1 Protection (k=12 paths/pairs):\n');
fprintf('\tWorst Link Load = %.2f Gbps\n', bestLoad);
fprintf('\tNumber of Solutions Explored = %d\n', contador);
fprintf('\tAverage Worst Link Load = %.2f Gbps\n', somador / contador);
fprintf('\tTime to Best Solution = %.2f seconds\n', bestLoadTime);

fprintf('\nRound-Trip Delays (ms):\n');
fprintf('\tService 1: Worst = %.2f ms, Average = %.2f ms\n', worstDelays(1), avgDelays(1));
fprintf('\tService 2: Worst = %.2f ms, Average = %.2f ms\n', worstDelays(2), avgDelays(2));
fprintf('\tService 3: Worst = %.2f ms, Average = %.2f ms\n', worstDelays(3), avgDelays(3));
