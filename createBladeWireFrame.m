function [H1,H2,H3] = createBladeWireFrame(bladefn,adfn,bladeLength,Psi,Theta,SweepAng,offset,plotFlag)
%createBladeWireFrame creates wireframe of component in hub frame
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [H1,H2,H3] = createBladeWireFrame(bladefn,adfn,bladeLength,Psi,...
%                                     Theta,SweepAng,offset,plotFlag)
%                    
%   This function creates a wireframe representation of a component by 
%   orienting and offsetting within a hub frame.
%
%      input:
%      bladefn     = string containing file name of component .dat file
%      adfn        = string containing file name of component .ipt file
%      bladeLngth  = length of component
%      Psi         = Psi orientation angle (deg, 1st 3 rotation)
%      Theta       = Theta orientation angle (deg, 2 rotation)
%      SweepAng    = Sweep orientation angle (deg, 2nd 3 rotation)
%      offset      = position vector offsetting component root from hub
%                    frame origin
%      plotFlag    = boolean activating or deactivating some intermediate
%                    plotting
%
%      output:   
%      H1          = h1 coordinates of component represnetation in hub
%                    frame
%      H2          = h2 coordinates of component represnetation in hub
%                    frame
%      H3          = h3 coordinates of component represnetation in hub
%                    frame

    blade = readFastBladeFile(bladefn); %read .dat file for component
    ad = readFastIpt(adfn);          %read .ipt file for component
    
    stationLoc = blade.prop.BlFract .* bladeLength; %calculate physical spanwise location
    stationTwist = blade.prop.StrcTwst.*pi/180;  %calculate station twist in radians
    
    %interpolate aerodynamic data at blade section in .dat file
    [b,nfoil] = interpolateAeroDataAtBladeSections(stationLoc,ad.RNodes,0.5.*ad.Chord,ad.NFoil); 
    
    deltaTheta = 15*pi/180;  %discretize blade section cross-section through a "sweep" of degrees
    theta=[0:deltaTheta:pi];
    leny=length(theta);  %get number of cross section descretizations
    lenb1 = length(stationLoc); %get number of blade sections
        
    for i=1:lenb1 %set arbitrary thickness to chord ratios based off of airfoil number, only used for visualization purposes
        if(nfoil(i) == 1)
            thicknessRatio = 1.0;
        elseif(nfoil(i) == 2)
            thicknessRatio = 0.6;
        elseif(nfoil(i) == 3)
            thicknessRatio = 0.3;
        else
            thicknessRatio = 0.2;
        end
        
        %create coordinates for blade wire frame B3 has upper and lower
        %surfaces denoted by B3u and B3l respectively
        B1(i,:) = stationLoc(i)*ones(1,leny);
        B2(i,:) = b(i).*cos(theta) + blade.prop.PreswpRef(i);
        B3u(i,:) = b(i).*sin(theta).*thicknessRatio + blade.prop.PrecrvRef(i);
        B3l(i,:) = -b(i).*sin(theta).*thicknessRatio + blade.prop.PrecrvRef(i);
        
        %twist section to account for visualization of structural twist
        [~,B3u(i,:)] = twistSection(stationTwist(i),B2(i,:),B3u(i,:));
        [B2(i,:),B3l(i,:)] = twistSection(stationTwist(i),B2(i,:),B3l(i,:));
    end
    
    %perform a transformation of the blade from a blade/body fixed frame to
    %the global/hub frame by a 3-2-3 Euler rotation sequency through Psi,
    %Theta, SweepAng
    [H1u,H2u,H3u] = rigidBodyRotation(B1,B2,B3u,[Psi,Theta,SweepAng],[3,2,3]);
    [H1l,H2l,H3l] = rigidBodyRotation(B1,B2,B3l,[Psi,Theta,SweepAng],[3,2,3]);
    
    %flip upper surface for a cleaner wireframe visualization
    H1l=flipud(H1l);
    H2l=flipud(H2l);
    H3l=flipud(H3l);
    
    %concatenate upper and lower surface coordinates for wireframe into 
    %single arrays of coordinates in the hub frame
    H1 = cat(1,H1u,H1l);
    H2 = cat(1,H2u,H2l);
    H3 = cat(1,H3u,H3l);
    
    %account for offset of component in visualization
    H1 = H1 + offset(1);
    H2 = H2 + offset(2);
    H3 = H3 + offset(3);
    
   %if plotFlag is true this visualizes original wireframe of component and
   %the applied transformation and offset 
   if(plotFlag)     
    hold on;
    axis equal;
    mesh(B1,B2,B3u,'EdgeColor','black');
    mesh(B1,B2,B3l,'EdgeColor','black');
    mesh(H1,H2,H3,'EdgeColor','red');
    view(3);
   end

end

function [B2new,B3new] = twistSection(twistAngle,B2,B3)
%This function transforms a vector through a single rotation about the "1"
%axis of angle twistAngle and outputs the transformed coordinates.

    ct = cos(twistAngle);
    st = sin(twistAngle);
    C = [1 0 0;0 ct st;0 -st ct]';
    
    B2new = C(2,2).*B2 + C(2,3).*B3;
    B3new = C(3,2).*B2 + C(3,3).*B3;
    
end

function [b,nfoil] = interpolateAeroDataAtBladeSections(R,aeroR,bAeroNode,nFoilAeroNode)
%This function interpolates aerodynamic properties from the aerodynamic
%domain in the .ipt file to the structural domain described in the .dat
%file. Semi-chord and airfoil number at the structural section of the
%component are output.

    %interpolate from aeronodes section
          %set root point and tip point
     if(abs(aeroR(1))>1.0e-4)
         aeroR = [R(1); aeroR];
         bAeroNode = [bAeroNode(1); bAeroNode];
         nFoilAeroNode = [nFoilAeroNode(1); nFoilAeroNode];
     end
     
     lenAeroR=length(aeroR);
     if(aeroR(lenAeroR) < R(length(R)))
         
         bslope = (bAeroNode(lenAeroR)-bAeroNode(lenAeroR-1))/(aeroR(lenAeroR)-aeroR(lenAeroR-1));
                  
         aeroR = [aeroR; R(length(R))];
         delRTip = aeroR(lenAeroR+1)-aeroR(lenAeroR);
         bAeroTip = bAeroNode(lenAeroR) + bslope*delRTip;
         
         bAeroNode = [bAeroNode; bAeroTip];
         nFoilAeroNode = [nFoilAeroNode;nFoilAeroNode(length(nFoilAeroNode))];
     end
     
     b = interp1(aeroR,bAeroNode,R);
     nfoil = interp1(aeroR,nFoilAeroNode,R,'nearest');
     % end interpolate from aero nodes section
 
end

