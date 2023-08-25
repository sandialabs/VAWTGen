function [component] = createComponent(component)
%createComponent creates a component oriented/positioned in the hub frame
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [component] = createComponent(component)
%                    
%   This function creates a component with the specified position and
%   orientation in the hub frame.
%
%      input:
%      component   = object containing component data
%
%      output:   
%      component   = object containing modified component data

bladefn     = component.fnname;   %assign component .dat filename
adfn        = component.adname;   %assign component .ipt filename
length      = component.length;   %assign length of component
Psi         = component.Psi;      %assign Psi orientation angle of component
Theta       = component.Theta;    %assign Theta orientation angle of component
SweepAng    = component.SweepAng; %assign SweepAng orientation angle of component

%assign  offset vector from hub frame origin to component root
offset = [component.xOffset, component.yOffset, component.zOffset];

%create elastic axis of component oriented/positioned in hub frame
[component.x,component.y,component.z]       = createComponentMesh(component,length,Psi,Theta,SweepAng,offset);
%create wire frame of component oriented/positioned in hub frame
[component.wfx,component.wfy,component.wfz] = createBladeWireFrame(bladefn,adfn,length,Psi,Theta,SweepAng,offset,0);

end

