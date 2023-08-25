function checkElementLengthRatios(componentList)
%printElementMaterial prints min. ratio of el length to component length
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   checkElementLengthRatios(componentList)
%                    
%   This functions prints minimum ratios of element length to component
%   length.
%
%      input:
%      componentList      = object containing component list data
%
%      output:       (NONE)

len = length(componentList);   %get number of components
fprintf('\nMinimum element to component length ratios:\n\n'); %prints a header to command line

for i=1:len 
    numStations = length(componentList{i}.props.BlFract); %get number of nodes in component i
    minRatio = 1.0e6;    %initialize some arbitrarily large minimum ratio
    for j=1:numStations-1 %loop over number of elements
        %get ratio of element length to component length as delta of blade fraction
        delta = componentList{i}.props.BlFract(j+1)-componentList{i}.props.BlFract(j); 
        
        if(delta<minRatio)  %update minimum ratio
            minRatio = delta; 
        end
    end
    fprintf('Component %i :\t %f\n',i,minRatio); %print minimum element length ratio

end

