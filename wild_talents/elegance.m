function [Sets, Width] = elegance(currentState,numRolls,numUnique,maxRolls,blankSets,blankWidth)
% function [Sets, Width] = elegance(currentState,numRolls,numUnique,maxRolls,blankSets,blankWidth)
%     Elegance is badass and recursive, nuff said
% 
%     Outputs:
%       PXSetsWithYDice is a probability table denoting the probability of
%           rolling X pairs (or better) with Y 10 sided dice
%       PWidthXWithYDice is a probability table denoting the probability of
%           rolling a set of X dice of the same number with Y 10 sided dice
% 
%     Inputs:
%       currentState is a list (of 8 bit integers) of the rolls made so far
%           listed ambiguously (i.e. 1 represents the first number rolled,
%           further 1s in the list represent a match to the first number)
%       numRolls is the number of rolls made so far
%       numUnique is the number of unique numbers rolled so far
%       maxRolls is the maximum number of rolls to recurse to
% 
%     Optional Inputs:
%       blankSets is a matrix of zeros of size equal to the expected result
%           PXSetsWithYDice
%       blankWidth is a matrix of zeros of size equal to the expected
%           result PWidthXWithYDice
% 
%     Usage:
%       [Sets, Width] = elegance(int8(1),1,1,10);
%       atLeastSets = fliplr(cumsum(fliplr(Sets),2));
%       atLeastWidth = fliplr(cumsum(fliplr(Width),2));
%       
%       Generates tables of probabilities for achieving at least X pairs
%       (X Sets) when rolling Y 10 sided dice and achieving a set of at
%       least X matching numbers (width X) when rolling Y 10 sided dice

if nargin == 0
    currentState = int8(1);
    numRolls = 1;
    numUnique = 1;
    maxRolls = 10;
    blankSets = zeros(maxRolls,(maxRolls/2)+1);
    blankWidth = zeros(maxRolls);
elseif nargin == 6
    blankSets = zeros(maxRolls,(maxRolls/2)+1);
    blankWidth = zeros(maxRolls);
else
    error('Invalid number of input arguments')
end

Width = blankWidth;
Sets = blankSets;

thisResult = zeros(1,10);
for i = 1:numRolls
    thisResult(currentState(i)) = thisResult(currentState(i)) + 1;
end
Sets(numRolls,sum(thisResult > 1)+1) = 1;
Width(numRolls,max(thisResult)) = 1;

if numRolls < maxRolls
    % Look into the next tier
    for i = 1:numUnique
        [nextSets, nextWidth] = elegance([currentState,int8(i)], numRolls+1, numUnique, maxRolls, blankSets, blankWidth);
        Sets = Sets + 0.1*nextSets;
        Width = Width + 0.1*nextWidth;
    end
    
    [nextSets, nextWidth] = elegance([currentState,int8(numUnique+1)], numRolls+1, numUnique+1, maxRolls, blankSets, blankWidth);
    Sets = Sets + 0.1*(10-numUnique)*nextSets;
    Width = Width + 0.1*(10-numUnique)*nextWidth;
end