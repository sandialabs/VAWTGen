function [H1,H2,H3] = createComponentMesh(comp,bladeLength,Psi,Theta,SweepAng,offset)
%createComponentMesh creates elastic axis of component in hub frame
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [H1,H2,H3] = createComponentMesh(comp,bladeLength,Psi,Theta,SweepAng,offset)
%                    
%   This function creates a representation of the elastic axis of a
%   component by orienting and offsetting within a hub frame.
%
%      input:
%      comp        = object with comonent data
%      bladeLngth  = length of component
%      Psi         = Psi orientation angle (deg, 1st 3 rotation)
%      Theta       = Theta orientation angle (deg, 2 rotation)
%      SweepAng    = Sweep orientation angle (deg, 2nd 3 rotation)
%      offset      = position vector offsetting component root from hub
%                    frame origin
%
%      output:   
%      H1          = h1 coordinates of component represnetation in hub
%                    frame
%      H2          = h2 coordinates of component represnetation in hub
%                    frame
%      H3          = h3 coordinates of component represnetation in hub
%                    frame
   
    stationLoc = comp.props.BlFract .* bladeLength; %calculate physical station locations along span of component

    lenb1 = length(stationLoc); %get number of nodes for component
    B1 = zeros(lenb1,1); %initialize body frame coordinate vectors
    B2 = B1;
    B3 = B1;
    for i=1:lenb1   %loop over number of nodes
        B1(i) = stationLoc(i);   %specify local coordinates of component
        B2(i) = comp.props.EdgEAOf(i) + comp.props.PreswpRef(i);
        B3(i) = comp.props.FlpEAOf(i) + comp.props.PrecrvRef(i);
    end
    
    %transform component from local frame to hub frame by specified
    %component orientation angles
    [H1,H2,H3] = rigidBodyRotation(B1,B2,B3,[Psi,Theta,SweepAng],[3,2,3]);
    
    %offset comonent from frame origin by desired position(offset) vector
    H1 = H1 + offset(1);
    H2 = H2 + offset(2);
    H3 = H3 + offset(3);
    
    %do check to see if first station of blade is at a lower elevation than
    %the last station of the blade.
    if(~strcmp(comp.type,'S'))
        if(H3(end) < H3(1))
            disp('WARNING: Component is positioned with first blade station at higher elevation than last blade station.')
            disp('For consistency, VAWTGen requires the firs blade station be at a lower elevation than the last blade station');
        end
    end
end

