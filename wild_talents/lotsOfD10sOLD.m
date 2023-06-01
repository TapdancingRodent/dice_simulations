function [maxHeight, maxWidth, maxSets] = lotsOfD10s(D,hD,wD,repeats)
% Initialise any missed variables
switch nargin
    case 0
        D = 3;
        hD = 0;
        wD = 1;
        repeats = 1e6;
    case 1
        hD = 0;
        wD = 1;
        repeats = 1e6;
    case 2
        wD = 1;
        repeats = 1e6;
    case 3
        repeats = 1e6;
    case 4
    otherwise
        error('Too many input arguments')
end

% Error prevention
if (D + hD + wD) > 10
    error('Function called with too many dice')
end

% Initialise results variables
maxHeight = zeros(1,11);
maxWidth = zeros(1,11);
maxSets = zeros(1,11);

for r = 1:repeats
    % Roll some dice
    Ds = randi(10,[1,D]);
    hDs = 9 * ones(1,hD);
    wDs = randi(10,[1,wD]);
    
    % Set up some variables for the possiblity generation loop
    tLim = min(10-wDs, 3*ones(1,wD));
    bLim = max(1-wDs, -3*ones(1,wD));
    wChoices = prod(tLim - bLim + 1);
    adjustment = bLim;
    
    if wD
        % Initialise some variables
        height = 0;
        width = 0;
        sets = 0;
        
        % Wiggle possibility generation loop
        for i = 1:wChoices       
            % Evaluate this possibility
            wDsAux = wDs + adjustment;
            thisRoll = [Ds, hDs, wDsAux];
            
%             % Long ass method of calculating
%             setsAux = 0;
%             for j = 1:10
%                 widthAux = sum(thisRoll == j);
%                 if widthAux > 1
%                     height = j;
%                     if widthAux > width
%                         width = widthAux;
%                     end
%                     setsAux = setsAux + 1;
%                 end
%             end
%             
%             if setsAux > sets
%                 sets = setsAux;
%             end
            
            % Slightly shorter method
            heights = zeros(1,10);
            for j = 1:length(thisRoll)
                heights(thisRoll(j)) = heights(thisRoll(j)) + 1;
            end
            
            if any(heights > 1)
                if max(heights) > width
                    width = max(heights);
                end
                heights = (heights > 1);
                if sum(heights) > sets
                    sets = sum(heights);
                end
                heights = find(heights);
                if heights(end) > height
                    height = heights(end);
                end
            end
            
            % Generate the next possibility
            j = 1;
            adjustment(j) = adjustment(j) + 1;
            while (adjustment(j) > tLim(j)) && (j < wD)
                adjustment(j) = bLim(j);
                j = j + 1;
                adjustment(j) = adjustment(j) + 1;
            end
        end
        
        maxHeight(height + 1) = maxHeight(height + 1) + 1;
        maxWidth(width + 1) = maxWidth(width + 1) + 1;
        maxSets(sets + 1) = maxSets(sets + 1) + 1;
    else
        % Evaluate this roll
        thisRoll = [Ds, hDs];
        for j = 1:10
            widthAux = sum(thisRoll == j);
            if widthAux > 2
                height = j;
                if widthAux > width
                    width = widthAux;
                end
                sets = sets + 1;
            end
        end
        
        maxHeight(height + 1) = maxHeight(height + 1) + 1;
        maxWidth(width + 1) = maxWidth(width + 1) + 1;
        maxSets(sets + 1) = maxSets(sets + 1) + 1;
    end
end

maxHeight = maxHeight / repeats;
maxWidth = maxWidth / repeats;
maxSets = maxSets / repeats;