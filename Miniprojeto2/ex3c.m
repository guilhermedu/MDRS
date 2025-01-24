clear all
close all
clc

% Load input data
load('InputDataProject2.mat');

nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);
k = 12;
timeLimit = 60;

v = 2e5; 
D = L / v; 
anycast_nodes = [4,12];
Taux = zeros(nFlows, 4);
nSP = zeros(nFlows, 1);
delays = cell(nFlows, 1);
numPathsPerFlow = zeros(nFlows, 1);
sP = cell(2, nFlows);

for f = 1:nFlows
    if T(f, 1) == 1  % Tipo do fluxo: Unicast 1
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{1, f} = shortestPath;
        sP{2, f} = {};
        nSP(f) = length(shortestPath{1});
        numPaths = length(totalCost); 
        numPathsPerFlow(f) = numPaths; 
        delays{f} = totalCost;
        Taux(f, :) = T(f, 2:5);
    elseif T(f, 1) == 2  % Tipo do fluxo: Unicast 2
        [shortestPath, secondPath, totalCost] = kShortestPathPairs(D, T(f, 2), T(f, 3), k);
        sP{1, f} = shortestPath;
        sP{2, f} = secondPath;
        nSP(f) = length(shortestPath{1});
        numPaths = length(totalCost);
        numPathsPerFlow(f) = numPaths; 
        delays{f} = totalCost;
        Taux(f, :) = T(f, 2:5);
    elseif T(f, 1) == 3  % Tipo do fluxo: Anycast
        if ismember(T(f, 2), anycast_nodes)
            sP{1, f} = {T(f, 2)};
            sP{2, f} = {};
            nSP(f) = 1;
            Taux(f, :) = T(f, 2:5);
            Taux(f, 2) = T(f, 2);
        else
            cost = inf;
            Taux(f, :) = T(f, 2:5);
            for i = anycast_nodes
                [shortestPath, totalCost] = kShortestPath(D, T(f, 2), i, 1);
                numPaths = length(totalCost);
                numPathsPerFlow(f) = numPaths;
                if max(totalCost) < cost
                    sP{1, f} = shortestPath;
                    nSP(f) = 1;
                    cost = totalCost;
                    delays{f} = totalCost;
                    Taux(f, 2) = i;
                end
            end
        end
    end
end

tStart = tic;
bestObjective = inf;
noCycles = 0;
totalObjective = 0;
while toc(tStart) < timeLimit
        sol = greedyRandomizedStrategy1(nNodes, Links, Taux, sP, numPathsPerFlow);
        [sol, objective] = HillClimbingStrategy1(nNodes, Links, Taux, sP, numPathsPerFlow, sol);
        totalObjective = totalObjective + objective;
        noCycles = noCycles + 1;
        if objective < bestObjective
            bestObjective = objective;
            bestSol = sol;
            timeSolution = toc(tStart);
        end
end
avObjective = totalObjective / noCycles;

worstDelay_s1 = max([delays{T(:,1) == 1}]); 
averageDelay_s1 = mean([delays{T(:,1) == 1}]);

worstDelay_s2 = max([delays{T(:,1) == 2}]);
averageDelay_s2 = mean([delays{T(:,1) == 2}]);

worstDelay_s3 = max([delays{T(:,1) == 3}]); 
averageDelay_s3 = mean([delays{T(:,1) == 3}]); 


fprintf("Multi start hill climbing with greedy randomized, anycast in nodes 4 and 12:\n")
fprintf("W = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n", bestObjective, noCycles, avObjective, timeSolution)
fprintf("Unicast 1 - Worst round-trip delay: %.2f ms\n", worstDelay_s1 * 2 * 10^3)
fprintf("Unicast 1 - Average round-trip delay: %.2f ms\n", averageDelay_s1 * 2 * 10^3)
fprintf("Unicast 2 - Worst round-trip delay: %.2f ms\n", worstDelay_s2 * 2 * 10^3)
fprintf("Unicast 2 - Average round-trip delay: %.2f ms\n", averageDelay_s2 * 2 * 10^3)
fprintf("Anycast - Worst round-trip delay: %.2f ms\n", worstDelay_s3 * 2 * 10^3)
fprintf("Anycast - Average round-trip delay: %.2f ms\n", averageDelay_s3 * 2 * 10^3)
