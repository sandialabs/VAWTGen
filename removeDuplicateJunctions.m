function [newJunctionList] = removeDuplicateJunctions(junctionList)
%removeDuplicateJunctions removes duplicate junctions in junctionList
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [newJunctionList] = removeDuplicateJunctions(junctionList)
%                    
%   The search procedure for locating component junctions can result in
%   duplicate junctions being found. This function removes duplicate
%   junctions from the junctionList object.
%
%      input:
%      junctionList     = object contatining junction information (with
%                         duplicate information)
%
%      output:       
%      newJunctionList  = object contatining junction information (without
%                         duplicate information)

[~,len] = size(junctionList); %get number of junctions in junctionList
if(len==0)
    newJunctionList = []; %create newJunctionList to hold unique Junctions
end

for i=1:len %loop over number of junctions
   for j=1:len %loop over number of junctions
      if(i~=j)
        if((junctionList{i}.comp1 == junctionList{j}.comp2) && (junctionList{i}.comp2 == junctionList{j}.comp1))
          junctionList{j}.comp1 = 0;  %if a duplicate junction is found, zero out junction list for entry "j"
          junctionList{j}.comp2 = 0;
        end
      end
   end
end

count = 1;
for i=1:len %loop over number of junctions
    if(junctionList{i}.comp1 ~= 0) %if junction hasn't been zeroed out by previous loop insert into new junction list
       newJunctionList{count} = junctionList{i};
       count = count + 1;
    end    
end

end

