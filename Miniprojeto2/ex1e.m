clear all;
close all;
clc;

% Load input data
load('InputDataProject2.mat');

% Constants
v = 2e5; % Speed of light in fiber (km/s)

% Calculate propagation delay matrix (in seconds)
D = L / v;

% Initialize variables
nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
nFlows = size(T, 1);
allCombinations = nchoosek(1:nNodes, 2); % All combinations of two nodes

bestAverageDelay = inf; % Initialize the best average round-trip delay
bestCombination = [];

% Iterate through all combinations of two nodes
for combIdx = 1:size(allCombinations, 1)
    % Select anycast nodes for the current combination
    anycastNodes = allCombinations(combIdx, :);

    sP = cell(1, nFlows);
    nSP = zeros(1, nFlows);
    atrasos = zeros(1, nFlows);
    Taux = zeros(nFlows, 4);

    for f = 1:nFlows
        if T(f, 1) == 1 || T(f, 1) == 2  % Unicast services
            [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), 1);
            sP{f} = shortestPath;
            nSP(f) = length(shortestPath);
            atrasos(f) = 2 * totalCost; % Round-trip delay
            Taux(f, :) = T(f, 2:5);
        elseif T(f, 1) == 3 % Anycast service
            Taux(f, :) = T(f, 2:5);
            [shortestPath1, totalCost1] = kShortestPath(D, T(f, 2), anycastNodes(1), 1);
            [shortestPath2, totalCost2] = kShortestPath(D, T(f, 2), anycastNodes(2), 1);
            if ismember(T(f, 2), anycastNodes)
                sP{f} = {T(f, 2)};
                nSP(f) = 1;
                Taux(f, 2) = T(f, 2);
            else
                if totalCost1 < totalCost2
                    sP{f} = shortestPath1;
                    nSP(f) = length(shortestPath1);
                    atrasos(f) = 2 * totalCost1; % Round-trip delay
                    Taux(f, 2) = anycastNodes(1);
                else
                    sP{f} = shortestPath2;
                    nSP(f) = length(shortestPath2);
                    atrasos(f) = 2 * totalCost2;
                    Taux(f, 2) = anycastNodes(2);
                end
            end
        end
    end

    % Compute the average round-trip delay for the current combination
    anycastDelays = atrasos(T(:, 1) == 3);
    averageAnycastDelay = mean(anycastDelays) * 1000; % Convert to milliseconds

    if averageAnycastDelay < bestAverageDelay
        bestAverageDelay = averageAnycastDelay;
        bestCombination = anycastNodes;
        bestUnicast1Delays = atrasos(T(:, 1) == 1);
        bestUnicast2Delays = atrasos(T(:, 1) == 2);
        bestAnycastDelays = anycastDelays;
        bestSP = sP; 
    end
end

% Compute the link loads for the best combination
sol = ones(1, nFlows);
Loads = calculateLinkLoads(nNodes, Links, Taux, bestSP, sol);
bestWorstLoad = max(max(Loads(:, 3:4))); % Compute the worst link load for the best combination

% Compute metrics for the best combination
averageUnicast1Delay = mean(bestUnicast1Delays) * 1000; % Convert to milliseconds
worstUnicast1Delay = max(bestUnicast1Delays) * 1000; % Convert to milliseconds
averageUnicast2Delay = mean(bestUnicast2Delays) * 1000; % Convert to milliseconds
worstUnicast2Delay = max(bestUnicast2Delays) * 1000; % Convert to milliseconds
worstAnycastDelay = max(bestAnycastDelays) * 1000; % Convert to milliseconds

% Display results
fprintf('Best anycast nodes = %d %d\n', bestCombination(1), bestCombination(2));
fprintf('Average round-trip delay (anycast service 3) = %.2f ms\n', bestAverageDelay);
fprintf('Worst link load = %.2f Gbps\n', bestWorstLoad);
fprintf('Worst round-trip delay (unicast service 1) = %.2f ms\n', worstUnicast1Delay);
fprintf('Average round-trip delay (unicast service 1) = %.2f ms\n', averageUnicast1Delay);
fprintf('Worst round-trip delay (unicast service 2) = %.2f ms\n', worstUnicast2Delay);
fprintf('Average round-trip delay (unicast service 2) = %.2f ms\n', averageUnicast2Delay);
fprintf('Worst round-trip delay (anycast service 3) = %.2f ms\n', worstAnycastDelay);
