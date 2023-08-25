function printElementOrientation(elOr,meshout)
%printElementMaterial prints element orientation data to file
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   printElementOrientation(elOr,meshout)
%                    
%   This functions prints element orientation data to file.
%
%      input:
%      elOR      = object containing element orientation data
%      meshout   = string containing prefix of orientation data file name
%
%      output:   (NONE)

fid = fopen([meshout,'.ort'],'wt'); %open element orientation file

len = length(elOr.elNum); %get number of elements

for i=1:len   %loop over number of elements
    % print element number, element Psi angle, element Theta angle, element
    % Twist angle, element length, and element offset from coordinate frame
    % origin (last two are useful in later visualization of element
    % orientation data)
   fprintf(fid,'%i\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e \n',[elOr.elNum(i), elOr.Psi(i), elOr.Theta(i), elOr.Twist(i), elOr.Length(i), elOr.Offset(:,i)']); 
end

fclose(fid); %close element orientation file

end

