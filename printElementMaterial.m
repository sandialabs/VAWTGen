function printElementMaterial(componentList,meshname)
%printElementMaterial prints element material data to file
% **********************************************************************
% *                   Part of  SNL VAWTGen                             *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   printElementMaterial(componentList,meshname)
%                    
%   This function prints element material data to file.
%
%      input:
%      componentList      = object containing component list data
%      meshname           = string containing prefix of element data file
%                            name
%
%      output:       (NONE)

meshname=[meshname,'.el']; %construct element data file name
fid=fopen(meshname,'wt');  %open element data file

    len = length(componentList); %gets number of components used to create mesh
    for i=1:len                  %loops over number of components
        prop = componentList{i}.props;  %gets property array for component i
        numSec = length(componentList{i}.props.BlFract); %gets number of sections (node) in component i
        for j=1:numSec-1 %loops over number of elements in component i
            
        %creates a 2 x 17 array of element data (a row for each node)
        %column 1 = spanwise fraction along component
        %column 2 = aerodynamic center location
        %column 3 = structural twist
        %column 4 = mass density along length of section
        %column 5 = flapwise stiffness
        %column 6 = edgewise stiffness
        %column 7 = torsional stiffness/rigidity
        %column 8 = axial/extensional stiffness
        %column 9 = pre curve
        %column 10 = pre sweep
        %column 11 = flapwise cg offset
        %column 12 = edgewise cg offset
        %column 13 = flapwise elastic axis offset
        %column 14 = edgewise elastic axis offset
        
        %get displacement vector from elastic axis to mass center
        edge_massCenter1 = prop.EdgcgOf(j) - prop.EdgEAOf(j); %for node 1 of element
        flap_massCenter1 = prop.FlpcgOf(j) - prop.FlpEAOf(j);
        
        edge_massCenter2 = prop.EdgcgOf(j+1) - prop.EdgEAOf(j+1); %for node 2 of element
        flap_massCenter2 = prop.FlpcgOf(j+1) - prop.FlpEAOf(j+1);
        
        %for struts VAWTGen orients these elements with local flapwise
        %vertical, and local edgewise positive toward the leading edge.
        %since properites in the input file have edgewise offsets specified
        %positive towards the trailing edge a conversion must take place.
        if(strcmp(componentList{i}.type,'S')) 
           edge_massCenter1 = -edge_massCenter1;
           edge_massCenter2 = -edge_massCenter2;
        end
        if(strcmp(componentList{i}.type,'T')) 
           flap_massCenter1 = -flap_massCenter1;
           flap_massCenter2 = -flap_massCenter2;
        end
        
        dataRow = [prop.BlFract(j), prop.AeroCent(j), prop.StrcTwst(j), prop.BMassDen(j),...
                   prop.FlpStff(j), prop.EdgStff(j), prop.GJStff(j), prop.EAStff(j),...
                   prop.Alpha(j), prop.FlpIner(j), prop.EdgIner(j), prop.PrecrvRef(j),...
                   prop.PreswpRef(j), flap_massCenter1, edge_massCenter1, prop.FlpEAOf(j), prop.EdgEAOf(j);
                   prop.BlFract(j+1), prop.AeroCent(j+1), prop.StrcTwst(j+1), prop.BMassDen(j+1),...
                   prop.FlpStff(j+1), prop.EdgStff(j+1), prop.GJStff(j+1), prop.EAStff(j+1),...
                   prop.Alpha(j+1), prop.FlpIner(j+1), prop.EdgIner(j+1), prop.PrecrvRef(j+1),...
                   prop.PreswpRef(j+1), flap_massCenter2, edge_massCenter2, prop.FlpEAOf(j+1), prop.EdgEAOf(j+1)];
        
        %prints element properties to file
        fprintf(fid,'%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\n',dataRow(1,:));
        fprintf(fid,'%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\n',dataRow(2,:));
        end
    end
fclose(fid); %closes element file
end

