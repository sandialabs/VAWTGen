function [model] = readInput(inputfile)
%readInput reads main VAWTGen input file
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [model] = readInput(inputfile)
%                    
%   This functions reads in the main VAWTGen input file and stores data in
%   the model object.
%
%      input:
%      inputfile     = string containing input file name
 
%      output:
%      model         = object containing model data

fid = fopen(inputfile); %opens VAWTGen input file

model.towerHt = fscanf(fid,'%f',1);         [dum] = fgetl(fid); %read tower height
model.towerFn = fscanf(fid,'%s',1);         [dum] = fgetl(fid); %reads tower material data (.dat) filename
model.towerAd = fscanf(fid,'%s',1);         [dum] = fgetl(fid); %reads tower aero data filename (.ipt)
model.towerNumDiv = fscanf(fid,'%i',1);     [dum] = fgetl(fid); %reads number of divisions to make per tower element in (.dat) file

model.numBlades = fscanf(fid,'%i',1);       [dum] = fgetl(fid); %reads in number of blades

model.bladeLn = fscanf(fid,'%f',1);         [dum] = fgetl(fid); %reads in blade length
model.bladeFn = fscanf(fid,'%s',1);         [dum] = fgetl(fid); % reads in blade material data (.dat) filename
model.bladeAd = fscanf(fid,'%s',1);         [dum] = fgetl(fid); % reads in blade aero data (.ipt) filename
model.bladeElevation =  fscanf(fid,'%f',1); [dum] = fgetl(fid); % reads in blade root elevation
model.rotorRadius =  fscanf(fid,'%f',1);    [dum] = fgetl(fid); % reads in blade root radius
model.bladeTheta =  fscanf(fid,'%f',1);     [dum] = fgetl(fid); % reads in blade theta orientation angle
model.bladeSweepAng = fscanf(fid,'%f',1);   [dum] = fgetl(fid); % reads in blade sweep orientation angle
model.bladeNumDiv = fscanf(fid,'%i',1);     [dum] = fgetl(fid); % reads number of divisions to make per blade element in (.dat) file

model.numStrutsPerBlade =  fscanf(fid,'%i',1);  [dum] = fgetl(fid); %reads in number of struts per blade

for i=1:model.numStrutsPerBlade
   strutFn = fscanf(fid,'%s',1);            [dum] = fgetl(fid); % reads in strut material data (.dat) filename
   strutAd = fscanf(fid,'%s',1);            [dum] = fgetl(fid); % reads in strut aero data (.ipt) filename
   strutParam = fscanf(fid,'%f',2);         [dum] = fgetl(fid); % reads in array denoting strut position in terms 
                                                                % of spanwise tower and spanwise blade position
   strutTtoC = fscanf(fid,'%f',1);          [dum] = fgetl(fid); % reads in strut thickness to chord ratio
   model.strutFn(i,:) = strutFn;     %assigns strut input to model object
   model.strutAd(i,:) = strutAd;
   model.strutParam(i,:) = strutParam';
   model.strutTtoC(i) = strutTtoC;
   model.strutNumDiv(i,:) = fscanf(fid,'%i',1); [dum] = fgetl(fid);
end

fclose(fid); %close VAWTGen input file

end

