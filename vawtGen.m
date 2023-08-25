function vawtGen(varargin)
%vawtGen main executable function for the VAWTGen mesh generator
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   vawtGen(inputfile,meshout,renderFlag)
%                    
%   This function is the main executable function for the VAWTGen mesh
%   generator.
%
%      input:
%      inputfile            = varargin{1}: string containing input file name
%      meshout              = varargin{2}: string containing outpuf file name prefix
%      renderFlag           = varargin{3}: boolean flag to activate/deactivate surface
%                             rendering visualization of VAWT configuration
%      SMALL                = varargin{4}: tolerance on numerical zero
%
%      output:              (NONE)

disp('**********************************************************************');
disp('*                        SNL VAWTGen   V1.0                          *');
disp('* Developed by Sandia National Laboratories Wind Energy Technologies *');
disp('*             See license.txt for disclaimer information             *');
disp('**********************************************************************');

close all;  %close all open figure windows
%unpack input arguments
if(length(varargin) < 3 || length(varargin) > 4)
    error('Incorrect number of input parameters. Exiting.');
end

inputfile = varargin{1};
meshout = varargin{2};
renderFlag = varargin{3};

if(length(varargin)==3)
    disp('Zero tolerance set to default of 1.0e-6');
    SMALL = 1.0e-6;
elseif(length(varargin)==4)
    SMALL = varargin{4};
end
%====================================================================
%read in, initialization, initial visualization
try
[model] = readInput(inputfile);  %reads main VAWTGen input file
catch
   error('Unable to successfully read input file. Ensure input file exists and has correct format.'); 
end
[componentList] = InitializeAndCreateComponents(model); %initializes and creates components
visualizeVAWT(componentList,renderFlag); %visualizes VAWT as wireframe with elastic axis
%====================================================================
%calculations
[junctionList] = findComponentJunctions(componentList,meshout,SMALL); %find junction points between components
[junctionList] = removeDuplicateJunctions(junctionList); %consolidate junction list to remove duplicate junctions
[componentList] = insertJunctionNodes(junctionList,componentList); %insert junction nodes where necessary
checkElementLengthRatios(componentList); %check element length ratios to overall component length
[feamesh] = createMesh(componentList); %create finite element mesh
[elOr] = calculateElementOrientation(feamesh); %calculate element orientations
%====================================================================
%writing files, plotting mesh for inspection
plotCreatedMesh(feamesh); %plot finite element mesh for inspection
testOrientation(elOr); %plot element orientation vectors for inspection
printMesh(feamesh,meshout); %write finite element mesh to file
printElementMaterial(componentList,meshout); %write element material data to file
outputJointNodes(feamesh,elOr,meshout); %write joint data to file
printElementOrientation(elOr,meshout); %write element orientation to file
writeBladeFile(componentList,feamesh,meshout); %write blade data to file
writeBCFile(meshout); %write boundary condition file
writeMainFile(meshout); %write main file for SNL OWENS Toolkit

end