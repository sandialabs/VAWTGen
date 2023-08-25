function [H1,H2,H3] = rigidBodyRotation(B1,B2,B3,AngleArray,AxisArray)
%rigidBodyRotation rotates a vector through a rotation sequence
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [H1,H2,H3] = rigidBodyRotation(B1,B2,B3,AngleArray,AxisArray)
%                    
%   This function performs a coordinate transformation from a local
%   body "B"(element) frame to a common hub frame "H" via a 3-2-3 euler
%   rotation sequence 
%
%      input:
%      B1        = array containing body frame 1 coordinates of points to be
%                  mapped to the hub frame
%      B2        = array containing body frame 2 coordinates of points to be
%                  mapped to the hub frame
%      B3        = array containing body frame 3 coordinates of points to be
%                  mapped to the hub frame
%     AngleArray = Array of angles for Euler rotation sequence
%     AxisArray  = Array of axes for Euler rotation sequence
%
%      output:   
%      H1        = array containg hub frame 1 coordinates of points mapped
%                  to the hub frame from body frame
%      H2        = array containg hub frame 2 coordinates of points mapped
%                  to the hub frame from body frame
%      H3        = array containg hub frame 3 coordinates of points mapped
%                  to the hub frame from body frame

        %This function performs a coordinate transformation from a local
        %body "B"(element) frame to a common hub frame "H" via a 3-2-3 euler
        %rotation sequence 
        
        %That is CHtoB = [M3(SweepAngle)][M2(Theta)][M3(Psi)]; 
   
        %calculate coordinate transformation matrix from element frame to
        %hub frame (CBtoH)
        dcm = createGeneralTransformationMatrix(AngleArray,AxisArray);
        C = dcm';
    
        %transform body coordinatized vector to be coordinatized in the hub
        %frame
        H1 = C(1,1).*B1 + C(1,2).* B2 + C(1,3).*B3;
        H2 = C(2,1).*B1 + C(2,2).* B2 + C(2,3).*B3;
        H3 = C(3,1).*B1 + C(3,2).* B2 + C(3,3).*B3;
end