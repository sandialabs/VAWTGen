function [mesh] = renumberMesh(nodeMap,mesh)
%renumberMesh renumbers node numbers of a mesh
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [mesh] = renumberMesh(nodeMap,mesh)
%                    
%   This function renumbers nodes in a mesh using the nodeMap
%   array.
%
%      input:
%      nodeMap    = array containing a mapping of old node numbering to new
%                   node numbering
%      mesh       = object containing mesh data with old node numbering
%
%      output:   
%      mesh       = object containing mesh data with revised node
%                   numbering

numNodes = length(mesh.x);  %get number of nodes
[numEl,~] = size(mesh.conn); %get number of elements

%nodes
for i=1:numNodes  %loop over number of nodes
    oldnum = mesh.nodeNum(i);  %get old node nubmer
    mesh.nodeNum(i) = nodeMap(oldnum); %find corresponding new element number in nodeMap and update node number
end

%conn
for j=1:numEl  %loop over number of elements
    for k=1:2  %loop over nodes per element
        oldnum = mesh.conn(j,k+1); %get old node number in connectivity list
        mesh.conn(j,k+1) = nodeMap(oldnum);  %find corresponding new element number in nodeMap and update connectivity list
    end
end

end

