function visualizeVAWT(componentList,renderFlag)
%printElementMaterial visualizes wireframe of VAWT configuration
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   visualizeVAWT(componentList,renderFlag)
%                    
%   This function visualizes a wire frame of a VAWT configuration in a
%   MATLAB figure window.
%
%      input:
%      componentList   = list of objects containing component information
%      renderFlag      = boolean flag for 3D surface rendering on/off
%
%      output:   (NONE)

figure(100); %open figure
hold on;
numComponents = length(componentList); %number of components

for i=1:numComponents %loop over number of components
    comp = componentList{i}; %get component i data
    mesh(comp.wfx,comp.wfy,comp.wfz,'EdgeColor','black'); %plot a wireframe of component i (blake wire frame)
    plot3(comp.x,comp.y,comp.z,'-r.','LineWidth',2,'MarkerSize',5.0); %plot elastic axis of component i (red line)
end

alpha(0.3); %set transparancy of wire frame
title('Wireframe Visualization'); %wireframe plot title

view(3); % set axes and view for wireframe
axis equal;


if(renderFlag) %if 3D rendering is active
figure(200);  %open figure, set axes for wireframe with 3D surface rendering
hold on;
numComponents = length(componentList);  %number of components

for i=1:numComponents %loop over number of components
    comp = componentList{i}; %get component i data
    surf(comp.wfx,comp.wfy,comp.wfz,'FaceColor','red','EdgeColor','none'); %plot a surface rendering of component i
                                                                           %with red surface color and no edge lines
end
camlight left; lighting phong %set ligting options
title('Surface Render Visualization'); %surface rendering plot title

view(3); % set axes and view for wireframe
axis equal;


end

end

