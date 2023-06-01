%% This script evaluates the performance of a set of test configurations of
% ten sided dice, with probability distributions (defined in lotsOfD10()):
%    D - cost 1 - normal rolled dice D~U(1,10)
%   hD - cost 2 - hard (fixed) dice hD = 9
%   wD - cost 4 - wiggle (choosable) dice wD~U(1,10)+[-3,3]
%
% For each test configuration, lotsOfD10s() evaluates the probability of
% being able to choose a number of sets or a set with given height / width
%
% Results are stored in a variable named results, with structure:
%   Dimension 1 is the number of normal dice
%   Dimension 2 is the number of hard dice
%   Dimension 3 is the number of wiggle dice
%
% MATLAB indexing starts at 1 i.e.
%   Results for 8D are stored in results(9,1,1)
%   Results for 4D+1wD are stored in results(5,1,2)

%% Establish some variables
% A couple of boolean variables to set the operation mode
newData = false;
calculateFeatures = false;
dumpData = true;

% The number of dice rolls to evaluate for each test configuration
repeats = 100000;

if newData
    % List of test dice configurations for generating new results
    tests = [];
    for wD = 0:10
        for hD = 0:10
            for D = 0:10
                if wD+hD+D < 11 && wD+hD+D > 1
                    tests = [tests; wD,hD,D];
                end
            end
        end
    end

    % Pre-initialise a matrix of results
    results(max(tests(:,1)+1), max(tests(:,2)+1), max(tests(:,3)+1)) = ...
        struct('maxHeight', [], 'maxWidth', [], 'maxSets', [], ...
        'cost', [], 'fitness', [], 'utility', [], ...
        'heightFitness', [], 'widthFitness', [], 'setsFitness', [], ...
        'heightUtility', [], 'widthUtility', [], 'setsUtility',[]);
else
    % Generated list of test dice configurations for analysing every old result
    tests = [];
    for k = 1:size(results,3)
        for j = 1:size(results,2)
            for i = 1:size(results,1)
                if ~isempty(results(i,j,k).maxHeight)
                    tests = [tests; i-1,j-1,k-1];
                end
            end
        end
    end
end

if dumpData
    % Pre-initialise a database of results
    dataDump = zeros([size(tests,1),46]);
    wiggleMargin = 3;
    fprintf('Remember to set wiggleMargin! It is currently %2.0f\n',wiggleMargin)
end

if calculateFeatures
    % Fitness functions convert a spread of results into one number
    % Height fitness weights height linearly and has range [0,1]
    heightFitFun = @(h)(sum(h .* (linspace(0, 1, length(h)))));
    % Width fitness weights width logarithmically
    widthFitFun = @(w)(sum(w .* [0, log2(linspace(1, 10, length(w)-1)) / 2]));
    % Sets fitness weights no of sets logarithmically
    setsFitFun = @(s)(sum(s .* (log2(linspace(1, 50, length(s))) / 5)));
end

%% Iterate through each test configuration
for i = 1:size(tests,1)
    % Retrieve number of dice in this simulation
    D = tests(i,1); hD = tests(i,2); wD = tests(i,3);
    
    if newData
        % Run a set of simulations
        [maxHeight, maxWidth, maxSets] = lotsOfD10s(D,hD,wD,repeats);
        
        % Store the results
        results(D+1, hD+1, wD+1).maxHeight = maxHeight;
        results(D+1, hD+1, wD+1).maxWidth = maxWidth;
        results(D+1, hD+1, wD+1).maxSets = maxSets;
    else
        % Read the results
        maxHeight = results(D+1, hD+1, wD+1).maxHeight;
        maxWidth = results(D+1, hD+1, wD+1).maxWidth;
        maxSets = results(D+1, hD+1, wD+1).maxSets;
    end
    
    if calculateFeatures
        % Calculate and assign fitness of each feature and an aggregate
        results(D+1, hD+1, wD+1).cost = D + hD*2 + wD*4;
        results(D+1, hD+1, wD+1).heightFitness = heightFitFun(maxHeight);
        results(D+1, hD+1, wD+1).widthFitness = widthFitFun(maxWidth);
        results(D+1, hD+1, wD+1).setsFitness = setsFitFun(maxSets);
        results(D+1, hD+1, wD+1).fitness = results(D+1, hD+1, wD+1).heightFitness ...
            + results(D+1, hD+1, wD+1).widthFitness ...
            + results(D+1, hD+1, wD+1).setsFitness;
        
        % Divide by the cost of xp cost of the test configuration... for kicks!
        results(D+1, hD+1, wD+1).heightUtility = results(D+1, hD+1, wD+1).heightFitness / results(D+1, hD+1, wD+1).cost;
        results(D+1, hD+1, wD+1).widthUtility = results(D+1, hD+1, wD+1).widthFitness / results(D+1, hD+1, wD+1).cost;
        results(D+1, hD+1, wD+1).setsUtility = results(D+1, hD+1, wD+1).setsFitness / results(D+1, hD+1, wD+1).cost;
        results(D+1, hD+1, wD+1).utility = results(D+1, hD+1, wD+1).fitness / results(D+1, hD+1, wD+1).cost;
    end
    
    if dumpData
        dataDump(i,1) = D;
        dataDump(i,2) = hD;
        dataDump(i,3) = wD;
        dataDump(i,4) = results(D+1, hD+1, wD+1).cost;
        dataDump(i,5) = wiggleMargin;
        dataDump(i,6) = results(D+1, hD+1, wD+1).fitness;
        dataDump(i,7) = results(D+1, hD+1, wD+1).utility;
        dataDump(i,8:18) = results(D+1, hD+1, wD+1).maxHeight;
        dataDump(i,19) = results(D+1, hD+1, wD+1).heightFitness;
        dataDump(i,20) = results(D+1, hD+1, wD+1).heightUtility;
        dataDump(i,21:31) = results(D+1, hD+1, wD+1).maxWidth;
        dataDump(i,32) = results(D+1, hD+1, wD+1).widthFitness;
        dataDump(i,33) = results(D+1, hD+1, wD+1).widthUtility;
        dataDump(i,34:44) = results(D+1, hD+1, wD+1).maxSets;
        dataDump(i,45) = results(D+1, hD+1, wD+1).setsFitness;
        dataDump(i,46) = results(D+1, hD+1, wD+1).setsUtility;
    end
end

% %% A vague attempt to compare wiggle dice and normal dice
% wDvsD = zeros([size(results,1), size(results,3)]);
% for i = 1:size(results,1)
%     for j = 1:size(results,3)
%         if ~isempty(results(i,j).fitness)
%             wDvsD(i,j) = results(i,j).fitness;
%         end
%     end
% end
% surf(0:(size(results,1)-1), 0:(size(results,3)-1), wDvsD')
% xlabel('# of D')
% ylabel('# of wD')
% zlabel('Fitness')
% title('A plot of the power of various combinations of normal and wiggle dice')