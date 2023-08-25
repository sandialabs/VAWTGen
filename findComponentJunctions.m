function [junctionList] = findComponentJunctions(componentList,meshout,SMALL)
%findComponentJunctions finds junctions between components in model
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [junctionList] = findComponentJunctions(componentList,meshout)
%                    
%   This function creates a mesh object from component list data
%
%      input:
%      componentList  = list of objects containing component data
%      meshout        = string containing filename prefix
%      SMALL          = tolerance on numerical zero
%
%      output:    
%      junctionList   = list of objects containing junction data

meshout = [meshout,'.out'];   %craete filename for output log file
fid = fopen(meshout,'wt');    %open output log file

numComponents = length(componentList); %get number of components
junctionCount = 0;

for i=1:numComponents   %loop over number of components
     for j=1:numComponents  %loop over number of components
        if(i~=j) %do not compare a component to itself
            [~,numElI] = size(componentList{i}.x'); %get number of nodes in component i
            [~,numElJ] = size(componentList{j}.x'); %get number of nodes in componet j
            
            numElI = numElI-1; %get number of elements in component i
            numElJ = numElJ-1; %get number of elements in component j
            
            for k=1:numElI   %loop over elements in component i
                el1_1=[componentList{i}.x(k); componentList{i}.y(k); componentList{i}.z(k)]; %get node coordinates for element k of component i
                el1_2=[componentList{i}.x(k+1); componentList{i}.y(k+1); componentList{i}.z(k+1)];
                
                for m=1:numElJ  %loop over elements in component j
                    el2_1=[componentList{j}.x(m); componentList{j}.y(m); componentList{j}.z(m)]; %get node coordinates for element m of component j
                    el2_2=[componentList{j}.x(m+1); componentList{j}.y(m+1); componentList{j}.z(m+1)];
                    
                    %check for element intersection
                    %return point of intersection (intersectPoint), boolean
                    %flag (intersectFlag) if interesection was detected,
                    %distance of point along element k (dist1), distance of
                    %point along elment m (dist2)
                    SMALL = 1.0E-6;
                    [intersectPoint,intersectFlag,dist1,dist2] = checkElementIntersect(el1_1,el1_2,el2_1,el2_2,SMALL); 
                    
                    %if intersection was found print intersection data to
                    %output log file
                    if(intersectFlag)
                         junctionCount = junctionCount + 1;
                         jctString = [componentList{i}.type,'/',componentList{j}.type,' junction found (',num2str(i),'-',num2str(j),')'];
                         fprintf(fid,'%s\n',jctString);

                         %store junction data in junctionList
                         junctionList{junctionCount}.comp1 = i;
                         junctionList{junctionCount}.comp2 = j;
                         junctionList{junctionCount}.el1 = k;
                         junctionList{junctionCount}.el2 = m;
                         junctionList{junctionCount}.frac1 = dist1;
                         junctionList{junctionCount}.frac2 = dist2;
                         junctionList{junctionCount}.intersectPoint = intersectPoint;
                    end
                    
                end
            end
        end
    end
    
end

fclose(fid); %close output log file
if(junctionCount==0)  %if no junctions, return junctionList as empty array
    junctionList = [];
end

end

