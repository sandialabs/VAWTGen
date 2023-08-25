function testOrientation(elOr)
%testOrientation visualizes orientation angles in MATLAB Plot
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   testOrientation(elOr)
%                    
%   This function visualizes element orientation angles in a MATLAB figure
%   window.
%
%      input:
%      elOr       = object containing element orientation data
%
%      output:   (NONE)

figure(2000); %open figure
hold on; 
len = length(elOr.elNum); %get number of elements

for i=1:len %loop over elements
    bvec = [elOr.Length(i);0.0;0.0];   %define vectors for an element fixed coordinate system
    b2vec = [0.0; 1.0;0.0];
    b3vec = [0.0; 0.0; 1.0];
    Psi=elOr.Psi(i);                   %get orientation angles for element
    Theta=elOr.Theta(i);
    Twist=elOr.Twist(i);
    
    %rotate element coordinate system vectors via orientation angles to
    %common "hub frame" coordinate system
    [hvec_1,hvec_2,hvec_3] = rigidBodyRotation(bvec(1),bvec(2),bvec(3),[Psi,Theta,Twist],[3,2,1]);
    hvec = [hvec_1; hvec_2; hvec_3];
    [h2vec_1,h2vec_2,h2vec_3] = rigidBodyRotation(b2vec(1),b2vec(2),b2vec(3),[Psi,Theta,Twist],[3,2,1]);
    h2vec = [h2vec_1; h2vec_2; h2vec_3];
    [h3vec_1,h3vec_2,h3vec_3] = rigidBodyRotation(b3vec(1),b3vec(2),b3vec(3),[Psi,Theta,Twist],[3,2,1]);
    h3vec = [h3vec_1; h3vec_2; h3vec_3];

    vecFactor = 1.0;
    h2vec = (h2vec./norm(h2vec)).*vecFactor;
    h3vec = (h3vec./norm(h3vec)).*vecFactor;
        
    p1 = [0;0;0] + elOr.Offset(:,i);         %offset the element coordinate frame in the hub system to lie on top of element node #1
    p2 = [hvec(1);hvec(2);hvec(3)] + elOr.Offset(:,i);
    p22 = [h2vec(1);h2vec(2);h2vec(3)] + elOr.Offset(:,i);
    p23 = [h3vec(1);h3vec(2);h3vec(3)] + elOr.Offset(:,i);
    
    
    %plot element coordinate frame
    plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'-ko');
    plot3([p1(1) p22(1)],[p1(2) p22(2)],[p1(3) p22(3)],'-ro');
    plot3([p1(1) p23(1)],[p1(2) p23(2)],[p1(3) p23(3)],'-go');
    
end
% axis equal; %set axes, view angle, legend and title
view(3);
axis equal;
legend('e_1','e_2','e_3');
title('Element Orientation Visualization');
end
