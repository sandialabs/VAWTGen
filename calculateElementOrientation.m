function [elOr] = calculateElementOrientation(mesh)
%calculateElementOrientation calculates the orienation of elements in mesh
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [elOr] = calculateElementOrientation(mesh)
%                    
%   This function calculates the orientation of elements in a mesh.
%
%      input:
%      mesh       = object containing mesh data
% 
%      output:
%      elOr       = object containing element orientation data

[numEl,~] = size(mesh.conn); %get number of elements
Psi=zeros(numEl,1); %initialize Psi, Theta, Twist, and Offset Arrays
Theta=zeros(numEl,1);
twist=zeros(numEl,1);
Offset=zeros(3,numEl);    %offset is the hub frame coordinate of node 1 of the element
elNum=zeros(numEl,1); %initialize element number array


%calculate "mesh centroid"
meshCentroid = [mean(mesh.x);mean(mesh.y);mean(mesh.z)]; %calculate a geometric centroid using all nodal coordinates
lenv = zeros(numEl,1);
for i=1:numEl %loop over elements
    n1 = mesh.conn(i,2); %n1 := node number for node 1 of element i
    n2 = mesh.conn(i,3); %n2 := node number for node 2 of element i
    
   p1 = [mesh.x(n1);mesh.y(n1);mesh.z(n1)]; %nodal coordinates of n1
   p2 = [mesh.x(n2);mesh.y(n2);mesh.z(n2)]; %nodal coordinates of n2
   Offset(:,i) = p1; %set offset as position of n1
   
   v=p2-p1; %define vector from p1 to p2
   lenv(i) = norm(v,2); %calculate element lengtt
   
   [Psi(i),Theta(i)] = calculatePsiTheta(v); %calculate elment Psi and Theta angles for orientation
   elNum(i) = mesh.conn(i,1); %get elemetn number
   
   [nVec1,nVec2,nVec3] = rigidBodyRotation(0,0,1,[Psi(i),Theta(i)],[3,2]); %tranform a local normal "flapwise" vector in the element frame to the hub frame
   nVec = [nVec1; nVec2; nVec3];
       
   %for consistency, force the "flapwise" normal vector of an element to be
   %away from the machine
   
   if(strcmp(mesh.type(i),'S'))
       refVector = [0;0;1];
   elseif(strcmp(mesh.type(i),'T'))
       refVector = [1;0;0];
   else
       refVector = p1-meshCentroid;
   end
   refVector = refVector./norm(refVector);
   dotTest = dot(nVec,refVector);
   
   if(dotTest<0 && abs(dotTest)>1.0e-4) %if vectors are not more or less aligned the normal vector is pointed inwards, towards the turbine (twist by 180 degrees)
     twist(i) = 180.0;
   elseif(abs(dotTest)<1.0e-4)
       twisttemp = 90.0;
       [nVec1,nVec2,nVec3] = rigidBodyRotation(0,0,1,[Psi(i),Theta(i),twisttemp],[3,2,1]);
       nVec = [nVec1; nVec2; nVec3];
       dotTest2 = dot(nVec,refVector);
       if(dotTest2<0 && abs(dotTest2)>1.0e-4) %if vectors are not more or less aligned the normal vector is pointed inwards, towards the turbine (twist by 180 degrees)
            twist(i) = twisttemp+180.0;
            if(abs(abs(twist(i))-270.0) < 1.0e-3)
               twist(i) = -90.0; 
            end
       else
           twist(i) = twisttemp; 
       end
   else  %the normal vector is pointed outwards, away from the turbine (no twist necessary)
     twist(i) = 0.0;
   end

end


%assign data to element orientation (elOr) object
elOr.Psi = Psi;
elOr.Theta = Theta;
elOr.Twist = twist;
elOr.Length=lenv;
elOr.elNum = elNum;
elOr.Offset = Offset;

end
