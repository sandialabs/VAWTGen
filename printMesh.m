function printMesh(mesh,meshoutfile)
%printMesh writes mesh file for the OWENS Toolkit
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   printMesh(mesh,meshoutfile)
%                    
%   This functions writes a mesh file for the OWENS Toolkit
%
%      input:
%      mesh          = object containing mesh data
%      meshoutfile   = string containing prefix mesh file
 
%      output:       (NONE)

meshoutfiletemp=[meshoutfile,'.mesh']; %create mesh file name
fid=fopen(meshoutfiletemp,'wt');       %open mesh file

numNodes = length(mesh.x);    %get number of nodes in mesh
[numEl,~] = size(mesh.conn);  %get number of elements in mesh

fprintf(fid,'%i\t%i\n',[numNodes, numEl]);  %print number of nodes, number of elements
for i=1:numNodes
   fprintf(fid,'%i\t%12.10e\t%12.10e\t%12.10e \n',[mesh.nodeNum(i),mesh.x(i),mesh.y(i),mesh.z(i)]); %print node #, h1 coord, h2 coord, h3 coord
end

for i=1:numEl %print connectivity list
   fprintf(fid,'%i\t%i\t%i\t%i\n',[mesh.conn(i,1),2,mesh.conn(i,2),mesh.conn(i,3)]);  %print element number, node 1, node 2
end


fprintf(fid,'\n');
fprintf(fid,'%i\t',mesh.numberOfSegments);
for i=1:1:mesh.numberOfSegments
    fprintf(fid,'%i\t',mesh.numberOfElementsInSegment(i));
end

fclose(fid); %close mesh file
end

