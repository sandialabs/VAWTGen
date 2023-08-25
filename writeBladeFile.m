function writeBladeFile(componentList,mesh,filename)
%writeBladeFile writes blade data file
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
%      componentList      = list of objects containing blade data file
%      model              = object containing model data
%      mesh               = object containing mesh data
%      filename           = prefix of filename for blade filename output
%
%      output:   (NONE)
%
totalNumComponents = length(componentList); %get total number of components

startNodes=0;  %initialize variables
startEl=0;
bladeNum = 0;
index = 0;
strutNum = 0;
strutIndex = 0;
strutData = [];
for i=1:totalNumComponents %loop over number of components
    if(componentList{i}.type == 'B') %check component type for blade
        bladeNum = bladeNum + 1; %define blade number
        len = length(componentList{i}.props.BlFract); %get number of nodes in component i
        
        %map chord and airfoil number to structural domain
        [strChord] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.aeroChord,componentList{i}.props.BlFract.*componentList{i}.length,2);
        [strAFNum] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.airfoilIndex,componentList{i}.props.BlFract.*componentList{i}.length,1);
        
        %get structure element midpoints
        a=componentList{i}.props.BlFract.*componentList{i}.length;
        rMid=0.5*(a(1:end-1) + a(2:end));
        
        %map aerodynamic data (twist and LCS) to structure element mid
        %points
        [strTwist] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.aeroTwist,rMid,2);
        [strLCS] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.LCS,componentList{i}.props.BlFract.*componentList{i}.length,2);
        
        %get quarter chord location, normal, and tangential vector
        [xb,yb,zb,nVec,tVec] = getAeroProfileAndOrientation(componentList{i}.props.BlFract.*componentList{i}.length,...
                                                           componentList{i}.props.PreswpRef,componentList{i}.props.PrecrvRef,...
                                                           componentList{i}.Psi,componentList{i}.Theta,componentList{i}.SweepAng,strTwist,mesh,componentList{i}.xOffset,...
                                                           componentList{i}.yOffset,componentList{i}.zOffset);
       
       %map normal and tangential vectors to structural element mid points
       for m=1:3 
           nVecStr(m,:) = interp1(rMid,nVec(m,:),componentList{i}.props.BlFract.*componentList{i}.length,'linear','extrap');
           tVecStr(m,:) = interp1(rMid,tVec(m,:),componentList{i}.props.BlFract.*componentList{i}.length,'linear','extrap');
       end
       
       %normalize nvec and tvec at structural positions
       for j=1:len
           nVecStr(:,j) = nVecStr(:,j)./norm(nVecStr(:,j));
           tVecStr(:,j) = tVecStr(:,j)./norm(tVecStr(:,j));
       end

       for j=1:len %loop over number of nodes in component i
            index = index+1;
          
%             if(j<len)
%                 dcm=calculateLambdaSlim(elOr.Psi(startEl+j)*pi/180.0,elOr.Theta(startEl+j)*pi/180.0,strTwist(j)*pi/180.0);
% %                 qcadjust = (dcm')*[0;0.25*strChord(j);0]; %fast files are
% %                 generated with pitchAxis = 0.25 so reference axis is the
% %                 quarter chord...
%             else

%             end
            
             %populate blade data object
             bladeData(index,1) = bladeNum;
             bladeData(index,2) = componentList{i}.props.BlFract(j).*componentList{i}.length;
             bladeData(index,3) = startNodes + j;
             bladeData(index,4) = startEl + j;
             bladeData(index,5) = xb(j);
             bladeData(index,6) = yb(j);
             bladeData(index,7) = zb(j);
             bladeData(index,8:10) =  (nVecStr(:,j))';
             bladeData(index,11:13) = (tVecStr(:,j))';
             bladeData(index,14) = strChord(j);
             bladeData(index,15) = strAFNum(j);
             bladeData(index,16) = strLCS(j);
             if(j==length(componentList{i}.props.BlFract))
                bladeData(index,4)  = -1;
                bladeData(index,15) = -1;
             end
        end
    end
    
    if(componentList{i}.type == 'S')
        strutNum = strutNum - 1; %define strut number (struts are given negative numbers)
        len = length(componentList{i}.props.BlFract); %get number of nodes for component i
        
        %map chord and airfoil number to structural domain
        [strChord] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.aeroChord,componentList{i}.props.BlFract.*componentList{i}.length,2);
        [strAFNum] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.airfoilIndex,componentList{i}.props.BlFract.*componentList{i}.length,1);
        
        %get structure element midpoints
        a=componentList{i}.props.BlFract.*componentList{i}.length;
        rMid=0.5*(a(1:end-1) + a(2:end));
        %map aerodynamic twist to mid point of structural elements
        [strTwist] = mapADtoStruct(componentList{i}.aeroR,componentList{i}.aeroTwist,rMid,2);
        
        %get the coordinates of aerodynamic points for strut
       [xb,yb,zb,~,~] = getAeroProfileAndOrientation(componentList{i}.props.BlFract.*componentList{i}.length,...
                                                           componentList{i}.props.PreswpRef,componentList{i}.props.PrecrvRef,...
                                                           componentList{i}.Psi,componentList{i}.Theta,componentList{i}.SweepAng,strTwist,mesh,componentList{i}.xOffset,...
                                                           componentList{i}.yOffset,componentList{i}.zOffset);
        
                                                      

       for j=1:len %loop over nodes in component i
            strutIndex = strutIndex+1;
            

            %populate strut data object
             strutData(strutIndex,1) = strutNum;
             strutData(strutIndex,2) = componentList{i}.props.BlFract(j).*componentList{i}.length;
             strutData(strutIndex,3) = startNodes + j;
             strutData(strutIndex,4) = startEl + j;
             strutData(strutIndex,5) = xb(j);
             strutData(strutIndex,6) = yb(j);
             strutData(strutIndex,7) = zb(j);
             strutData(strutIndex,8) = strChord(j);
             strutData(strutIndex,9) = componentList{i}.TtoC;
             strutData(strutIndex,10) = componentList{i}.bladeIndex;
             if(j==length(componentList{i}.props.BlFract))
                strutData(strutIndex,4)  = -1;
             end
        end
        
        
    end
    
     %increment nodes and element associated with blades/struts
     startNodes = startNodes + length(componentList{i}.props.BlFract);
     startEl    = startEl + length(componentList{i}.props.BlFract)-1;
end

%write to file ..................
bladeoutfiletemp=[filename,'.bld']; %create blade file name
fid=fopen(bladeoutfiletemp,'wt');   %open blade file

if(bladeNum > 0)
[len,~]=size(bladeData);            %get number of rows in bladeData object

%print blade data to file
for i=1:len
    fprintf(fid,'%i\t%12.10e\t%i\t%i\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%i\t%12.10e',[bladeData(i,:)]);
    if(i~=len)
        fprintf(fid,'\n');
    end
end
fprintf(fid,'\n');
[len,~]=size(strutData); %get number of rows in strutData object
%print strut data to file
for i=1:len
    fprintf(fid,'%i\t%12.10e\t%i\t%i\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%12.10e\t%i',[strutData(i,:)]);
    if(i~=len)
        fprintf(fid,'\n');
    end
end
end

fclose(fid);  %close blade file

end

function [strProp] = mapADtoStruct(aeroR,aeroProp,structR,flag)
%This function maps aerodynamic properties at locations in aeroR to
%structural properties using the interpolation method denoted by "flag"
    if(flag==1)
        interpStr = 'nearest';
    elseif(flag==2)
        interpStr = 'linear';
    end
    
    strProp = interp1(aeroR,aeroProp,structR,interpStr,'extrap');

end

function [x,y,z,bladeSecNormal,bladeSecTE] = getAeroProfileAndOrientation(span,preswp,precrv,psi,theta,sweepAng,strTwist,mesh,xOffset,yOffset,zOffset)
%This function gets the aerodynamic quarter chord and normal and tangent
%vector associated with a blade section
xtemp = span; 
ytemp = preswp;
ztemp = precrv;

meshCentroid = [mean(mesh.x);mean(mesh.y);mean(mesh.z)]; %calculate a geometric centroid using all nodal coordinates

bc2 = zeros(3,length(xtemp));

for i=1:length(xtemp)
   [bc2(1,i),bc2(2,i),bc2(3,i)] = rigidBodyRotation(xtemp(i),ytemp(i),ztemp(i),[psi,theta,sweepAng],[3 2 3]);
end
x = bc2(1,:) + xOffset; %assign x y and z from transformed blade coordinates
y = bc2(2,:) + yOffset;
z = bc2(3,:) + zOffset;

for i=1:(length(bc2(1,:))-1) %loop over blade coordinates
    n1 = i;
    n2 = i+1;
    
    p1 = [x(n1);y(n1);z(n1)]; %get nodal coordinates associated with element
    p2 = [x(n2);y(n2);z(n2)];
   
    v=p2-p1; %calculate vector along element axis
   
    [psiB(i),thetaB(i)] = calculatePsiTheta(v); %calculate Psi and Theta orientation angles for blade
    
    %transform blade section normal to hub frame and account for twist
    [bladeSecNormal(1,i),bladeSecNormal(2,i),bladeSecNormal(3,i)] = rigidBodyRotation(0.0,0.0,1.0,[psiB(i),thetaB(i),strTwist(i)],[3 2 1]);

    [bladeSecTE(1,i),bladeSecTE(2,i),bladeSecTE(3,i)] = rigidBodyRotation(0.0,-1.0,0.0,[psiB(i),thetaB(i),strTwist(i)],[3 2 1]);

    %assumes reference axis (pre-sweep and pre-curve are the quarter chord)
    %[quarterChordAdjust]  = rigidRotationBlade([0;0.25*chord;0],psiB(i),thetaB(i),0.0);
    
    %check if this is the "inward normal"

    refVector = p1 - meshCentroid;
    refVector = refVector./norm(refVector);
    
    dotTest=dot(bladeSecNormal(:,i),-refVector);%if postive normal vec is probably inward, if negative normal vector is probably outward
    
    if(dotTest<0 && abs(dotTest)>1.0e-4) %if normal vector is outward, make machine inwards
        strTwist(i) = strTwist(i) + 180.0;
    elseif(abs(dotTest)<1.0e-4)
       twisttemp = 90.0 + strTwist(i);
       [nVec1,nVec2,nVec3] = rigidBodyRotation(0,0,1,[psiB(i),thetaB(i),twisttemp],[3,2,1]);
       nVec = [nVec1; nVec2; nVec3];
       dotTest2 = dot(nVec,-refVector);
       if(dotTest2<0 && abs(dotTest2)>1.0e-4) %if vectors are not more or less aligned the normal vector is pointed inwards, towards the turbine (twist by 180 degrees)
            strTwist(i) = twisttemp+180.0;
       else
            strTwist(i) = twisttemp; 
       end
    end
    
    [bladeSecNormal(1,i),bladeSecNormal(2,i),bladeSecNormal(3,i)] = rigidBodyRotation(0.0,0.0,1.0,[psiB(i),thetaB(i),strTwist(i)],[3 2 1]);
    [bladeSecTE(1,i),bladeSecTE(2,i),bladeSecTE(3,i)] = rigidBodyRotation(0.0,-1.0,0.0,[psiB(i),thetaB(i),strTwist(i)],[3 2 1]);

    %normalize
    bladeSecNormal(:,i) = bladeSecNormal(:,i)/norm(bladeSecNormal(:,i));
    bladeSecTE(:,i)     = bladeSecTE(:,i)/norm(bladeSecTE(:,i));

end

end
