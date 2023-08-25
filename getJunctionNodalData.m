function [junctionNodalData] = getJunctionNodalData(junctionList,numComponents)
%getJunctionNodalData identifies junctions that will require node insertion
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [junctionNodalData] = getJunctionNodalData(junctionList,numComponents)
%                    
%   This function identifies junctions that will require a new node be 
%   inserted.
%
%      input:
%      junctionList          = list of object containing junction data
%      numComponents         = number of components in model
% 
%      output:
%      junctionNodalData     = object containing junction nodal data for
%                              cases that will require a new node be 
%                              inserted
%
SMALL =1.0e-6; %define a small number for numeric zero
[~,len]=size(junctionList); %get 

for i=1:numComponents %initialize junction nodal data for components
   junctionNodalData{i}.el=[];
   junctionNodalData{i}.pt=[];
   junctionNodalData{i}.frac=[];
end

%compile list of junctions that will require a new node inserted storing
%data in junctionNodalData
for i=1:len
    comp1 = junctionList{i}.comp1; %component 1 associated with junction
    el1   = junctionList{i}.el1;   %element number of component 1 assocaited with junction
    frac1 = junctionList{i}.frac1; %fraction along el1 that junction occurs
    
    comp2 = junctionList{i}.comp2; %component 2 associated with junction
    el2   = junctionList{i}.el2;   %element number of component 2 assocaited with junction
    frac2 = junctionList{i}.frac2; %fraction along el2 that junction occurs
    
    point = junctionList{i}.intersectPoint; %coordinate associated with junction
    
    if(frac1 > 0.0 && frac1 < 1.0 && abs(frac1)>SMALL && abs(frac1-1)>SMALL)
        junctionNodalData{comp1}.el = cat(1,junctionNodalData{comp1}.el,el1);
        junctionNodalData{comp1}.pt = cat(1,junctionNodalData{comp1}.pt,point');
        junctionNodalData{comp1}.frac = cat(1,junctionNodalData{comp1}.frac,frac1);
    end
    
    if(frac2 > 0.0 && frac2 < 1.0 && abs(frac2)>SMALL && abs(frac2-1)>SMALL)
        junctionNodalData{comp2}.el = cat(1,junctionNodalData{comp2}.el,el2);
        junctionNodalData{comp2}.pt = cat(1,junctionNodalData{comp2}.pt,point');
        junctionNodalData{comp2}.frac = cat(1,junctionNodalData{comp2}.frac,frac2);
    end
end

%sort list in ascending order by element number
for i=1:numComponents
    fracSorted=[];
    pointSorted=[];
    [elSorted,map] = sort(junctionNodalData{i}.el);
    
    for j=1:length(elSorted)
       fracSorted(j) = junctionNodalData{i}.frac(map(j));
       pointSorted(j,:) = junctionNodalData{i}.pt(map(j),:);
    end
    junctionNodalData{i}.el = elSorted;
    junctionNodalData{i}.frac = fracSorted;
    junctionNodalData{i}.pt = pointSorted;
    
end

%trim list of duplicates here....
junctionNodalDataNew=[];
for i=1:numComponents %loop over number of components
    lenjnd = length(junctionNodalData{i}.el);
    activeFlag = ones(lenjnd,1);
   for j=1:lenjnd
      for k=1:lenjnd
          if(j~=k)
              if(activeFlag(j))
              if((junctionNodalData{i}.el(j) == junctionNodalData{i}.el(k)) && (abs(junctionNodalData{i}.frac(j)-junctionNodalData{i}.frac(k))<SMALL))
                activeFlag(k) = 0;
           
              end
              end
          end
      end
   end
   count = 1;
   for j=1:lenjnd
       if(activeFlag(j))
       junctionNodalDataNew{i}.el(count) = junctionNodalData{i}.el(j);
       junctionNodalDataNew{i}.frac(count) = junctionNodalData{i}.frac(j);
       junctionNodalDataNew{i}.pt(count,:) = junctionNodalData{i}.pt(j,:);
       count = count + 1;
       end
   end
   
end
    junctionNodalData = junctionNodalDataNew;
end

