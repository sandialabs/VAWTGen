function [Psi,Theta] = calculatePsiTheta(v)
%calculatePsiTheta calculates the orienation of a single element
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [Psi,Theta] = calculatePsiTheta(v)
%                    
%   This function calculates the orientation of a single element. A local
%   element frame is related to a hub frame through a transformation matrix
%   CHtoE (transforming a vector from an element frame E to a global frame
%   H) such that CHtoE = [M2(Theta)]*[M3(Psi)]. Here [M2( )] is a direction
%   cosine matrix about a 2 axis and [M3( )] is a direction cosine matrix
%   about a 3 axis.
%
%      input:
%      v          = vector from node 1 to node 2 of an element
% 
%      output:
%      Psi        = "3" angle for element orientation (deg)
%      Theta      = "2" angle for element orientation (deg)
%                   see above for definition

    v=v/norm(v); %normalize vector by its length
    
    Psi = atan2(v(2),v(1))*180.0/pi; %calculate sweep angle, convert to deg
	
    Theta = -asin(v(3))*180.0/pi; %calculate theta angle, convert to deg

end

