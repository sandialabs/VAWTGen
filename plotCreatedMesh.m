function plotCreatedMesh(mesh)
%plotCreatedMesh  plots mesh in MATLAB figure
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   plotCreatedMesh(mesh)
%                    
%   This functions plots the mesh with node number for visual inspection in
%   a MATLAB figure window
%
%      input:
%      mesh          = object contianing mesh data
%
%      output:       (NONE)

numNodes = length(mesh.x);   %get number of nodes in mesh
[numEl,~] = size(mesh.conn); %get number of element in mesh

figure(400); %create figure window
hold on;

nodeTracker = ones(numNodes,1); %create a variable to track if node number has been printed for a node

xMin = 1e6;
xMax = -1e6;
yMin = xMin;
yMax = xMax;
zMin = xMin;
zMax = xMax;

for i=1:numEl
    for k=1:numNodes  %print mesh by element
        if(mesh.nodeNum(k)==mesh.conn(i,2)) 
            p1 = k;                         %p1 is the node number of element i's node #1
        end
        if(mesh.nodeNum(k)==mesh.conn(i,3))
            p2 = k;                         %p2 is the node number of element i's node #2
        end            

    end
   x=[mesh.x(p1), mesh.x(p2)];              %construct x, y, and z arrays for nodes of element i
   y=[mesh.y(p1), mesh.y(p2)];
   z=[mesh.z(p1), mesh.z(p2)];
   fac = .005;                              %create a factor to offset element number labeling from nodal coordinate
   fac1 =  1 + fac;
   
   if(nodeTracker(p1))
   text(x(1)*fac1,y(1)*fac1,z(1)*fac1,num2str(p1));  %if node number has not been printed, create text box
   nodeTracker(p1) = 0;                              %mark node as having being printed in nodeTracker
   end
   if(nodeTracker(p2))
   text(x(2)*fac1,y(2)*fac1,z(2)*fac1,num2str(p2));  %if node number has not been printed, create text box
   nodeTracker(p2) = 0;                              %mark node as having being printed in nodeTracker
   end
   if(mod(i,2)==0)
       plot3(x,y,z,'-ok');         %plot even elements printed as black
   else
       plot3(x,y,z,'-or');         %plot odd eleents printed as red 
                                   %(to distinguish between alternating elements along a component)
   end
   
   %keep track of upper and lower axes limits
   xLimits = get(gca,'XLim');  %# Get the range of the x axis
   yLimits = get(gca,'YLim');  %# Get the range of the y axis
   zLimits = get(gca,'ZLim');  %# Get the range of the z axis
   
%    if(min(xLimits) < xMin)
%        xMin = min(xLimits);
%    end
%    if(min(yLimits) < yMin)
%        yMin = min(yLimits);
%    end
%    if(min(zLimits) < zMin)
%        zMin = min(zLimits);
%    end
%    if(max(xLimits) > xMax)
%        xMax = min(xLimits);
%    end
%    if(max(yLimits) > yMax)
%        yMax = min(yLimits);
%    end
%    if(max(zLimits) > zMin)
%        zMax = max(zLimits);
%    end
end
title('Finite Element Mesh');      %label MATLAB figure

   xLimits = get(gca,'XLim');  %# Get the range of the x axis
   yLimits = get(gca,'YLim');  %# Get the range of the y axis
   zLimits = get(gca,'ZLim');  %# Get the range of the z axis
   
   %if a certain axis has a range of numerical zero, correct it to prevent
   %problems with plotting later
   if(norm(xLimits)<1.0e-6)
       if(abs(yLimits(2)-yLimits(1)) < abs(zLimits(2)-zLimits(1)))
           xLimits = 0.1*zLimits;
       else
           xLimits = 0.1*yLimits;
       end
   end
   
   if(norm(yLimits)<1.0e-6)
       if(abs(xLimits(2)-xLimits(1)) < abs(zLimits(2)-zLimits(1)))
           yLimits = 0.1*zLimits;
       else
           yLimits = 0.1*xLimits;
       end
   end
   
   if(norm(zLimits)<1.0e-6)
       if(abs(xLimits(2)-xLimits(1)) < abs(yLimits(2)-yLimits(1)))
           zLimits = 0.1*yLimits;
       else
           zLimits = 0.1*xLimits;
       end
   end
           
axis([xLimits yLimits zLimits]);         
    
view(3);
axis equal; %set axes and view

end

