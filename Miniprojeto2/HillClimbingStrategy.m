function [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol)
    nFlows = length(sol);
    improved = true;
    
    while improved
        improved = false;
        currentLoad = calculateLinkLoads(nNodes, Links, T, sP, sol);
        currentMaxLoad = max(max(currentLoad(:,3:4)));
        
        for f = 1:nFlows
            for p = 1:nSP(f)
                if p ~= sol(f)
                    newSol = sol;
                    newSol(f) = p;
                    newLoad = calculateLinkLoads(nNodes, Links, T, sP, newSol);
                    newMaxLoad = max(max(newLoad(:,3:4)));
                    
                    if newMaxLoad < currentMaxLoad
                        sol = newSol;
                        currentMaxLoad = newMaxLoad;
                        improved = true;
                        break; 
                    end
                end
            end
            if improved
                break; 
            end
        end
    end
    
    load = currentMaxLoad;
end
