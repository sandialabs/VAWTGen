function [dcmTotal] = createGeneralTransformationMatrix(angleArray,axisArray)
%createGeneralTransformationMatrix  calculates general transformation matrix
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [dcmTotal] = createGeneralTransformationMatrix(angleArray,axisArray)
%                    
%   This function calculates the transformation matrix assocaited with a
%   general Euler rotation sequence.
%
%      input:
%      angleArray      = array of angles for Euler rotation sequence
%      axisArray       = array of axis of rotatoins for Euler rotation
%                        sequences
% 
%      output:
%      dcmTotal        = transformation matrix of specified euler rotation
%                        sequence

numRotations = length(angleArray); %get number of rotation to perform
dcmArray = zeros(3,3,numRotations); %initialize individual rotation direction cosine matrix arrays

for i=1:numRotations %calculate individual single rotatio direction cosine matrices
	dcmArray(:,:,i) = createSingleRotationDCM(angleArray(i),axisArray(i));
end

dcmTotal = dcmArray(:,:,1); %initialize dcmTotal as first rotation 

%multiply consecutive rotation sequency direction cosine matrices to arrive at overall transformation matrix
for i=2:1:numRotations
	dcmTotal = dcmArray(:,:,i)*dcmTotal; 
end

end

function [dcm] = createSingleRotationDCM(angleDeg,axisNum)
%This function creates a direction cosine matrix (dcm) associated
%with a rotation of angleDeg about axisNum.

	angleRad = angleDeg*pi/180.0; %convert angle to radians
	
	if(axisNum == 1) %direction cosine matrix about 1 axis
		dcm = [1.0 0.0 0.0; 0.0 cos(angleRad) sin(angleRad); 0.0 -sin(angleRad) cos(angleRad)];
	elseif(axisNum == 2) %direction cosine matrix about 2 axis
		dcm = [cos(angleRad) 0.0 -sin(angleRad); 0.0 1.0 0.0; sin(angleRad) 0.0 cos(angleRad)];
	elseif(axisNum == 3) %direction cosine matrix about 3 axis
		dcm = [cos(angleRad) sin(angleRad) 0.0; -sin(angleRad) cos(angleRad) 0.0; 0.0 0.0 1.0];
    else  %error catch
		error('Error: createSingleRotationDCM. Axis number must be 1, 2, or 3.');
	end

end