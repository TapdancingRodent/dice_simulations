function [maxHeight, maxWidth, maxSets] = lotsOfD10s(D,hD,wD,repeats)
% function [maxHeight, maxWidth, maxSets] = lotsOfD10s(D,hD,wD,repeats)
%   lostOfD10s evaluates simulated rolls of 10 sided dice. A successful
%   roll results in 2 or more dice with the same face value. The varieties
%   of dice have the following probability distributions:
%        D - cost 1 - normal rolled dice D~U(1,10)
%       hD - cost 2 - hard (fixed) dice hD = 9
%       wD - cost 4 - wiggle (choosable) dice wD~U(1,10)+[-3,3]
%       
%   Outputs:
%       maxHeight is a vector of probabilities that a given height (0-10)
%           is the maximum possible on a single roll
%       maxWidth is a vector of probabilities that a given width (0-10)
%           is the maximum possible on a single roll
%       maxSets is a vector of probabilities that a given number of sets
%           (0-10) is the maximum possible on a single roll
%
%   Inputs:
%        D is the number of normal dice to simulate
%       hD is the number of hard dice to simulate
%       wD is the number of wiggle dice to simulate
%
%   Optional Inputs:
%       repeats is the number of simulated dice rolls to evaluate
%       
%   Usage:
%       [maxHeight, maxWidth, maxSets] = lotsOfD10s(4,0,2)
%       fprintf('The probability of rolling a set of 10s is %0.4f\n',maxHeight(end))
%       fprintf('The probability of rolling a set at width 3 is %0.4f\n',maxWidth(4))
%       fprintf('The probability of rolling at least two sets is %0.4f\n',sum(maxSets(3:end)))

% Initialise any missing variables
switch nargin
    case 0
        D = 3;
        hD = 0;
        wD = 1;
        repeats = 1e5;
    case 1
        hD = 0;
        wD = 1;
        repeats = 1e5;
    case 2
        wD = 1;
        repeats = 1e5;
    case 3
        repeats = 1e5;
    case 4
    otherwise
        error('Too many input arguments')
end

% Error prevention
if (D + hD + wD) > 10
    error('Function called with too many dice')
end

% Parameters
wiggleMargin = 3;
hDValue = 9;

% Initialise results variables
maxHeight = zeros(1,11);
maxWidth = zeros(1,11);
maxSets = zeros(1,11);

% Roll lots of dice
for r = 1:repeats
    % Roll some dice
    Ds = randi(10,[1,D]);
    hDs = hDValue * ones([1,hD]);
    wDs = randi(10,[1,wD]);
    
    %% Determine max height and max width
    % First note down the "rolled" dice
    rolled = zeros(1,10);
    for i = [Ds, hDs]
        rolled(i) = rolled(i) + 1;
    end
    setChoices = rolled;
    
    % Then allowing wD to take many values at once
    tLim = min(wDs + wiggleMargin, 10*ones(1,wD));
    bLim = max(wDs - wiggleMargin, 1*ones(1,wD));
    for j = 1:wD
        setChoices(bLim(j):tLim(j)) = setChoices(bLim(j):tLim(j)) + 1;
    end
    
    % Only count complete sets
    height = max((setChoices > 1) .* (1:10));
    width = max((setChoices > 1) .* setChoices);
    
    %% Determine maximum number of sets
    % 1. Work out what choices of wD value can complete sets
    % possibleChoices holds a list of useful ways to set wiggle dice
    completeSets = zeros([1,10]);
    possibleChoices = zeros([(min([2*wiggleMargin+1,10])*wD*(wD-1)/2 + (D+hD)*wD + 1),4],'uint8');
    choiceIndex = 1;
    
    for i = 1:10
        switch rolled(i)
            % no rolled dice of this height - only a pair of nearby wiggles
            % can complete a set at this height
            case 0
                closeEnough = abs(wDs - i) <= wiggleMargin;
                for j = 1:wD-1
                    if closeEnough(j)
                        for k = (j+1):wD
                            if closeEnough(k)
                                possibleChoices(choiceIndex,1) = i;
                                possibleChoices(choiceIndex,2) = j;
                                possibleChoices(choiceIndex,3) = k;
                                choiceIndex = choiceIndex + 1;
                            end
                        end
                    end
                end
            % one rolled dice of this height - any nearby wiggles could
            % complete a set at this height
            case 1
                closeEnough = abs(wDs - i) <= wiggleMargin;
                for j = 1:wD
                    if closeEnough(j)
                            possibleChoices(choiceIndex,1) = i;
                            possibleChoices(choiceIndex,2) = j;
                            choiceIndex = choiceIndex + 1;
                    end
                end
            % two or more rolled dice of this height - a set has been made
            otherwise
                completeSets(i) = 1;
        end
    end
    
    % 2. Determine what impact completing a given set has on the pool
    heightPossibleChoices = zeros([1,10]);
    wPossibleChoices = zeros([1,wD]);
    C = 1;
    i = possibleChoices(C,1);
    while i ~= 0
        j = possibleChoices(C,2); k = possibleChoices(C,3);
        
        % we can get a set of height i in heightPossibleChoices(i) ways
        % wiggle dice j can complete a set in wPossibleChoices(j) ways
        heightPossibleChoices(i) = heightPossibleChoices(i) + 1;
        wPossibleChoices(j) = wPossibleChoices(j) + 1;
        if k
            wPossibleChoices(k) = wPossibleChoices(k) + 1;
        end
        
        C = C + 1;
        i = possibleChoices(C,1);
    end
    
    possibleChoices = possibleChoices(1:C-1,:);
    
    % Determine how many potential sets are lost by fixing a given wiggle
    for C = 1:size(possibleChoices,1)
        i = possibleChoices(C,1); j = possibleChoices(C,2); k = possibleChoices(C,3);
        if k
            possibleChoices(C,4) = heightPossibleChoices(i) + wPossibleChoices(j) + wPossibleChoices(k);
        else
            possibleChoices(C,4) = heightPossibleChoices(i) + wPossibleChoices(j);
        end
    end
    
    % Sort the wiggle dice choices into least-impact order
    possibleChoices = sortrows(possibleChoices,[4]);
    
    % 3. Complete sets in an optimal (least-impact first) fashion
    for C = 1:size(possibleChoices,1)
        i = possibleChoices(C,1); j = possibleChoices(C,2); k = possibleChoices(C,3);
        if i
            completeSets(i) = 1;
            if k
                for s = size(possibleChoices,1):-1:1
                    if (possibleChoices(s,1) == i) || (possibleChoices(s,2) == j)  || (possibleChoices(s,3) == j) ...
                            || (possibleChoices(s,2) == k)  || (possibleChoices(s,3) == k)
                        possibleChoices(s,1) = 0;
                    end
                end
            else
                for s = size(possibleChoices,1):-1:1
                    if (possibleChoices(s,1) == i) || (possibleChoices(s,2) == j) || (possibleChoices(s,3) == j)
                        possibleChoices(s,1) = 0;
                    end
                end
            end
        end
    end
    sets = sum(completeSets);
    
    % Calculate a selection of possible choices
    maxHeight(height + 1) = maxHeight(height + 1) + 1;
    maxWidth(width + 1) = maxWidth(width + 1) + 1;
    maxSets(sets + 1) = maxSets(sets + 1) + 1;
end

% Average
maxHeight = maxHeight / repeats;
maxWidth = maxWidth / repeats;
maxSets = maxSets / repeats;

end