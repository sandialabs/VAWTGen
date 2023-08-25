function outputJointNodes(feamesh,elOr,filename)
%outputJointNodes writes the joint data file
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   outputJointNodes(feamesh,elOr,filename)
%                    
%   This function writes the joint data file.
%
%      input:
%      feamesh               = object containing finite element mesh data
%      elOr                  = object containing element orientation
%                              data
%      filename              = filename prefix for joint data file
% 
%      output:               (NONE)

    x = feamesh.x;  %define x, y, z from mesh
    y = feamesh.y;
    z = feamesh.z;
    newdeac = [];
    len=length(x);  %get number of nodes
    deactivate = zeros(len,3); %
    count = 1;
    SMALL = 1.0e-6; %define a small number that is zero for practical purposes
    for i=1:len
        for j=1:len
            if(i~=j && ~deactivate(i,1)) %do not compare a point to itself, do not compare point if it has already been deactivated
                if(abs(x(i)-x(j))<SMALL && abs(y(i)-y(j))<SMALL && abs(z(i)-z(j))<SMALL) %if points are coincident
                   deactivate(j,:) = [1,i,j];  %add i and j combination to deactivate array (i is master, j is a slave node)
                   newdeac(count,:) = [i,j];   %add i and j combination to newdeac array
                   count = count +1;
                end
            end
        end
    end
    
   dupCount = sum(deactivate(:,1)); %count number of duplicate nodes
   
   fn = [filename, '.jnt'];  %create joint filename
   fid = fopen(fn,'w');      %open joint file
   
   [numJoints,~] = size(newdeac);
   fprintf('\n\n%i Joints located:\n\n',numJoints);
   for i=1:dupCount %loop over duplicate nodes
        [elNumSlave] = searchConnectivityForNodeNum(newdeac(i,2),feamesh.conn); %find element number associated with slave node
        [elNumMaster] = searchConnectivityForNodeNum(newdeac(i,1),feamesh.conn); %find element number associated with master node
        
        fprintf('Joint %i:\tMaster - Node #%i,\tComponent Type %s\n',i,newdeac(i,1),feamesh.type(elNumMaster));
        fprintf('\t\t\tSlave  - Node #%i,\tComponent Type %s\n\n',newdeac(i,2),feamesh.type(elNumSlave));
        
        %output joint #, master node #, slave node #, joint type (hard
        %coded to zero for fixed/welded constraint - user may adjust file 
        %after generation), place holder for mass and stiffness associated
        %with joint, orientation (Psi and Theta) of master node.
        if(i<dupCount)
            fprintf(fid,'%i\t%i\t%i\t%i\t%3.2e\t%3.2e\t%f\t%f\n',[i,newdeac(i,1),newdeac(i,2),0,0.0,0.0,elOr.Psi(elNumSlave),elOr.Theta(elNumSlave)]);
        else
            fprintf(fid,'%i\t%i\t%i\t%i\t%3.2e\t%3.2e\t%f\t%f',[i,newdeac(i,1),newdeac(i,2),0,0.0,0.0,elOr.Psi(elNumSlave),elOr.Theta(elNumSlave)]);
        end
   end
   fclose(fid); %close joint file

end

function [elNum] = searchConnectivityForNodeNum(nodeNum,conn)
%This function searches the connectivity list for a node number.
    a = ismember(conn(:,2),nodeNum);
    elNum=find(a);

    if(isempty(elNum))
        a = ismember(conn(:,3),nodeNum);
        elNum=find(a);
    end
end
