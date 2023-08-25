function writeBCFile(meshout)
%writeBCFile writes a boundary condition file for the OWENS Toolkit
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   writeBCFile(meshout)
%                    
%   This function writes a boundary condition file for the OWENS Toolkit
%
%      input:
%      meshout     = string containing input prefix of file name
 
%      output:     (NONE)

    fn = [meshout,'.bc'];    %construct file name
    fid = fopen(fn,'wt');    %open boundary condition file
    
    fprintf(fid,'%i\n',6);   %hardwired for a cantilevered boundary condition on node 1
    for i=1:6
       fprintf(fid,'%i %i %f\n',[1 i 0.0]); 
    end
    
    fclose(fid); %close boundary condition file
    
end
