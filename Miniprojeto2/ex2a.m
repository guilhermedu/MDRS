clear all
close all
clc

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

% Computing up to k=inf shortest paths for all flows from 1 to nFlows:
k= 12;
sP= cell(1,nFlows);
nSP= zeros(1,nFlows);
for f=1:nFlows
    [shortestPath, totalCost] = kShortestPath(L,T(f,1),T(f,2),k);
    sP{f}= shortestPath;
    nSP(f)= length(totalCost);
end
% sP{f}{i} is the i-th path of flow f
% nSP(f) is the number of paths of flow f

% Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows);
Loads= calculateLinkLoads(nNodes,Links,T,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

t= tic;
timeLimit= 30;
bestLoad= inf;
contador= 0;
somador= 0;
while toc(t) < timeLimit
    % greedy randomzied start
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);
    

    if load<bestLoad
        bestSol= sol;
        bestLoad= load;
        bestLoads= Loads;
        bestLoadTime = toc(t);
    end
    contador= contador + 1;
    somador= somador + load;
end

fprintf('Multi start hill climbing with greedy randomized (all possible paths):\n');
fprintf('\t W = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', bestLoad, contador, somador/contador, bestLoadTime);

