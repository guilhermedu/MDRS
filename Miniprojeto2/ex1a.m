clear all;
close all;
clc;

% Load input data
load('InputDataProject2.mat');

% Constants
v = 2e5; % Speed of light in fiber (km/s)

% Calculate propagation delay matrix (in seconds)
D = L / v;

% Define anycast nodes for service 3
anycastNodes = [3, 10];

% Initialize variables
nFlows = size(T, 1);
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
atrasos = zeros(1, nFlows);

for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2  % Unicast services (s = 1 and s = 2)
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), 1);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        atrasos(f) = 2 * totalCost; 
    elseif T(f, 1) == 3  % Anycast service (s = 3)
        [shortestPath1, totalCost1] = kShortestPath(D, T(f, 2), anycastNodes(1), 1);
        [shortestPath2, totalCost2] = kShortestPath(D, T(f, 2), anycastNodes(2), 1);
        if ismember(T(f,2),anycastNodes)
            sP{f}={T(f,2)};
            nSP(f)=1;
        else
            if totalCost1 < totalCost2
                sP{f} = shortestPath1;
                nSP(f) = length(totalCost1);
                atrasos(f) = 2 * totalCost1; 
            else
                sP{f} = shortestPath2;
                nSP(f) = length(totalCost2);
                atrasos(f) = 2 * totalCost2;
            end
        end
    end
end

% Separate delays by service type
unicast1Delays = atrasos(T(:, 1) == 1);
unicast2Delays = atrasos(T(:, 1) == 2);
anycastDelays = atrasos(T(:, 1) == 3);

% Compute metrics
worstUnicast1Delay = max(unicast1Delays) * 1000;
averageUnicast1Delay = mean(unicast1Delays) * 1000;
worstUnicast2Delay = max(unicast2Delays) * 1000;
averageUnicast2Delay = mean(unicast2Delays) * 1000;
worstAnycastDelay = max(anycastDelays) * 1000;
averageAnycastDelay = mean(anycastDelays) * 1000;

% Display results
fprintf('Anycast nodes = %d %d\n', anycastNodes(1), anycastNodes(2));
fprintf('Worst round-trip delay (unicast service 1) = %.2f ms\n', worstUnicast1Delay);
fprintf('Average round-trip delay (unicast service 1) = %.2f ms\n', averageUnicast1Delay);
fprintf('Worst round-trip delay (unicast service 2) = %.2f ms\n', worstUnicast2Delay);
fprintf('Average round-trip delay (unicast service 2) = %.2f ms\n', averageUnicast2Delay);
fprintf('Worst round-trip delay (anycast service) = %.2f ms\n', worstAnycastDelay);
fprintf('Average round-trip delay (anycast service) = %.2f ms\n', averageAnycastDelay);