function [mesh] = createMesh(componentList)
%createMesh creates a mesh object from component list data
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [mesh] = createMesh(componentList)
%                    
%   This function creates a mesh object from component list data
%
%      input:
%      componentList  = list of objects containing component data
%
%      output:    
%      mesh           = object containing mesh data

x=[]; %initialize null arrays for x, y, z, and node number
y=[];
z=[];
nodeNum=[];
[~,len] = size(componentList); %get number of components
startIndex = 0;
for i=1:len %loop over component list
    [lenx,~]=size(componentList{i}.x); %get number of nodes in component i
       x = cat(2,x,componentList{i}.x'); %concatenate x, y, z
       y = cat(2,y,componentList{i}.y');
       z = cat(2,z,componentList{i}.z');
    for j=1:lenx %loop over number of nodes in component i
       startIndex = startIndex + 1;
       nodeNum(startIndex) = startIndex; %assign node number
    end
end

%assign mesh nodal data to mesh object
mesh.x=x; 
mesh.y=y;
mesh.z=z;
mesh.nodeNum=nodeNum;


count = 1;
indexOffset = 0;
for i=1:len %loop over component list
    [lenx,~]=size(componentList{i}.x); %get number of nodes in component i
   for j=1:lenx-1 %loop over number of elemetns in component i
       %create connectivity for local element j in component i
       conn(count,:) = [count, j+indexOffset,j+indexOffset+1]; 
       compType(count) = componentList{i}.type;
       count=count+1;
   end
   indexOffset = indexOffset + lenx;
   
   elementsInComponent(i) = lenx-1;
   
end
mesh.conn=conn; %assign connectivity list to mesh object
mesh.type = compType; %assign component type associated with elements to mesh objects

%get number of mesh segments
mesh.numberOfSegments = len;
mesh.numberOfElementsInSegment = elementsInComponent;

end

