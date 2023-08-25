function writeMainFile(meshout)
%writeMainFile writes the main file for the OWENS Toolkit
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   writeMainFile(meshout)
%                    
%   This function writes the main file for the OWENS Toolkit.
%
%      input:
%      meshout     = string containing input prefix of file name
 
%      output:     (NONE)   

    fn = [meshout,'.owens'];          %create main file name
    
    fid = fopen(fn,'wt');             %opens main file
    dumstr = [meshout,'.mesh'];       %writes mesh file name
    fprintf(fid,'%s\n',dumstr);
    dumstr = [meshout,'.el'];         %writes element data file name
    fprintf(fid,'%s\n',dumstr);  
    dumstr = [meshout,'.ort'];        %writes element orientation file name
    fprintf(fid,'%s\n',dumstr);
    dumstr = [meshout,'.jnt'];        %writes joint data file name
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['[concentrated_nodal_term_file]']; %write place holder for nodal terms file
    fprintf(fid,'%s\n',dumstr);
    dumstr = [meshout,'.bc'];         %writes boundary condition file name
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['0 [platform_property_file]']; %writes place holder for platform property file
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['[initial_conditions_file]'];   %writes place holder for initial conditions file
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['0 ',meshout,'.bld ', '[aero_loads_file]']; %writes: flag for deactivating CACTUS loads, writes blade file name, place holder for loads file
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['0 [drivetrain_property_file]']; %writes place holder for drive train property file
    fprintf(fid,'%s\n',dumstr);
    dumstr = ['[generator_property_file]'];  %writes placeholder generator property file
    fprintf(fid,'%s\n',dumstr);
    fprintf(fid,'%f\t',[0.0 0.0]);           %writes rayleigh damping paramters (zeros)
    
    fclose(fid);                     %closes main file
   
end