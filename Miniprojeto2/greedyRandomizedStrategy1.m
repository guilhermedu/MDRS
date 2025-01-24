function sol = greedyRandomizedStrategy1(nNodes, Links, T, sP, nSP)
    nFlows = size(T, 1);
    sol = zeros(1, nFlows);
    
    for f = 1:nFlows
        candidatePaths = 1:nSP(f);
        pathLoads = zeros(1, nSP(f));
        for p = candidatePaths
            tempSol = sol;
            tempSol(f) = p;
            Loads = calculateLinkBand1to1(nNodes, Links, T, sP, tempSol);
            pathLoads(p) = max(max(Loads(:,3:4)));
        end
        % Seleciona o caminho com menor carga com um elemento de aleatoriedade
        [~, sortedIndices] = sort(pathLoads);
        if isempty(sortedIndices)
            selectedPath = 1;
        else
            selectedPath = sortedIndices(randi(min(3, nSP(f)))); % Seleciona um dos 3 melhores caminhos
        end
        sol(f) = selectedPath;
    end
end