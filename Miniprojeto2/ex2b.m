clear all
close all
clc

load('InputDataProject2.mat')

% Constants
v = 2e5; % Speed of light in fiber (km/s)
D = L / v; % Propagation delay matrix (in seconds)

K = 6; % Number of shortest paths
anycastNodes = [1,6];
nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
nFlows = size(T, 1);

% Preallocation
delays = cell(nFlows, 1);
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
Taux = zeros(nFlows, 4);

% Compute shortest paths for each flow and fill Taux
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2  % Unicast services
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), K);
        sP{f} = shortestPath;
        nSP(f) = length(shortestPath);
        delays{f} = totalCost;
        Taux(f, :) = T(f, 2:5);
    elseif T(f, 1) == 3 % Anycast service
        Taux(f, :) = T(f, 2:5);
        % Caso o nó origem já seja um anycast node
        if ismember(T(f, 2), anycastNodes)
            sP{f} = {T(f, 2)};
            nSP(f) = 1;
            Taux(f, 2) = T(f, 2);
            delays{f} = 0; 
        else
            [shortestPath1, totalCost1] = kShortestPath(D, T(f, 2), anycastNodes(1), 1);
            [shortestPath2, totalCost2] = kShortestPath(D, T(f, 2), anycastNodes(2), 1);

            % Comparar os custos totais e escolher o menor
            if totalCost1 < totalCost2
                sP{f} = shortestPath1;
                nSP(f) = length(shortestPath1);
                delays{f} = totalCost1; 
                Taux(f, 2) = anycastNodes(1);
            else
                sP{f} = shortestPath2;
                nSP(f) = length(shortestPath2);
                delays{f} = totalCost2;
                Taux(f, 2) = anycastNodes(2);
            end
        end
    end
end

% Multi-start hill climbing with greedy randomized approach
t = tic;
timeLimit = 30;
bestLoad = inf;
contador = 0;
somador = 0;
bestCycle = 0; 

while toc(t) < timeLimit
    sol = greedyRandomizedStrategy(nNodes, Links, Taux, sP, nSP);

    [sol, load] = HillClimbingStrategy(nNodes, Links, Taux, sP, nSP, sol);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoadTime = toc(t);
        bestCycle = contador; 
    end
    contador = contador + 1;
    somador = somador + load;
end

% Display results
fprintf('Multi start hill climbing with greedy randomized (specific nodes 1 and 6 for anycast):\n');
fprintf('\t W = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', bestLoad, contador, somador / contador, bestLoadTime);
fprintf('Total number of cycles run: %d\n', contador);
fprintf('Time when the best solution was found: %.2f sec\n', bestLoadTime);
fprintf('Cycle when the best solution was found: %d\n', bestCycle);

% Compute delay metrics by service type
unicast1Delays = [delays{T(:, 1) == 1}];
unicast2Delays = [delays{T(:, 1) == 2}];
anycastDelays = [delays{T(:, 1) == 3}];

% Compute metrics for unicast service 1
worstUnicast1Delay = max(unicast1Delays) * 2 * 1000; 
averageUnicast1Delay = mean(unicast1Delays) * 2 * 1000; 

% Compute metrics for unicast service 2
worstUnicast2Delay = max(unicast2Delays) * 2 * 1000;
averageUnicast2Delay = mean(unicast2Delays) * 2 * 1000; 

% Compute metrics for anycast service
worstAnycastDelay = max(anycastDelays) * 2 * 1000; 
averageAnycastDelay = mean(anycastDelays) * 2 * 1000; 

% Display delay results
fprintf('Anycast nodes = %d %d\n', anycastNodes(1), anycastNodes(2));
fprintf('Worst round-trip delay (unicast service 1) = %.2f ms\n', worstUnicast1Delay);
fprintf('Average round-trip delay (unicast service 1) = %.2f ms\n', averageUnicast1Delay);
fprintf('Worst round-trip delay (unicast service 2) = %.2f ms\n', worstUnicast2Delay);
fprintf('Average round-trip delay (unicast service 2) = %.2f ms\n', averageUnicast2Delay);
fprintf('Worst round-trip delay (anycast service 3) = %.2f ms\n', worstAnycastDelay);
fprintf('Average round-trip delay (anycast service 3) = %.2f ms\n', averageAnycastDelay);
