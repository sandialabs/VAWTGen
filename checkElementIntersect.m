function [intersectPoint,intersectFlag,dist1,dist2] = checkElementIntersect(el1_1,el1_2,el2_1,el2_2,SMALL)
%checkElementIntersect checks two elements for intersection
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [intersectPoint,intersectFlag,dist1,dist2] = 
%                          checkElementIntersect(el1_1,el1_2,el2_1,el2_2)
%                    
%   This function checks for an intersection point between two elements.
%   Uses logic from: 
%   http://mathforum.org/library/drmath/view/62814.html
%   http://geomalgorithms.com/a07-_distance.html#dist3D_Segment_to_Segment
%
%      input:
%      el1_1     = coordinates of node 1 on element 1
%      el1_2     = coordiantes of node 2 on element 1
%      el2_1     = coordinates of node 1 on element 2
%      el2_2     = coordinates of node 2 on element 2
%      SMALL     = tolerance on numerical zero
%
%      output:
%      intersectionPoint = coordinate of intersection point
%      intersectFlag     = boolean flag, true if intersection found between
%                          elements
%      dist1             = distance of intersection along element 1
%      dist2             = distance of intersection along element 2




%initializion
intersectFlag= false;

%Assume lines are of the form:
%line1 = a + x1*V1
%line2 = b + x2*V2

%calculate vector along element axis for el1 and el2
V1 = el1_2-el1_1;
V2 = el2_2-el2_1;

%calculate vector between node #1 of element 1 to node #1 of element 2
distanceBetweenNode1s = el1_1 - el2_1;

dotV1V1 = dot(V1,V1);  %dot procuct of V1 and V2
dotV1V2 = dot(V1,V2);  %dot product of V1 and V2
dotV2V2 = dot(V2,V2);  %dot product of V2 and V2
dotV1Dist = dot(V1,distanceBetweenNode1s);  %dot product between W0 and V1
dotV2Dist = dot(V2,distanceBetweenNode1s);  %dot product between V0 and V2

denom=(dotV1V1*dotV2V2-dotV1V2*dotV1V2);  %This is the squared magnitude of V1 x V2

SMALL = 1.0e-6;
if(abs(denom)<SMALL)  %This checks if lines are parallel
    domainPointOnLine1 = 0.0;
    if(dotV1V1 > dotV2V2)
        domainPointOnLine2 = dotV1Dist/dotV1V2;
    else
        domainPointOnLine2 = dotV2Dist/dotV2V2;
    end
else
    domainPointOnLine1 = (dotV1V2*dotV2Dist - dotV2V2*dotV1Dist )/denom;    %calculates coordinate closest point on "line 1"
    domainPointOnLine2 = (dotV1V1*dotV2Dist - dotV1V2*dotV1Dist )/denom;    %calculates coordinate of closest point on "line 2"
end

distVec = distanceBetweenNode1s + (domainPointOnLine1*V1) - (domainPointOnLine2*V2);  %calculates the closest distance vector between the two lines
distance = sqrt(dot(distVec,distVec));  %calculates the distance vector
intersectPoint = el1_1 + domainPointOnLine1*V1;
dist1 = domainPointOnLine1;
dist2 = domainPointOnLine2;

    if(distance < SMALL) %check if distance is "zero"
                  
            %check if intersection point is within line segments 
            %(i.e. inside element) and set flag to true if so
            [flag1] = isPointInsideLineSegment(intersectPoint,el1_1,el1_2,SMALL);
            [flag2] = isPointInsideLineSegment(intersectPoint,el2_1,el2_2,SMALL);
            
            %if point is inside line segment of each element set
            %intersection flag to true
            if(flag1 && flag2) 
                intersectFlag = true;
            end
    end

end

function [flag] = isPointInsideLineSegment(point,el_1,el_2,SMALL)
%This function receives the coordinate of a point (point) and two
%coordinates describing the end points of a line segment (el_1, el_2),
%determines if point is between these two end points and returns a boolean
%as true or false (flag).

    %initialize flags
    flag = false;
    flagx=false;
    flagy=false;
    flagz=false;

    %check if point's x coordinate is between end point's x coordinates
    if((point(1) > el_1(1) && point(1) < el_2(1)) || (point(1) < el_1(1) && point(1) > el_2(1)))
        flagx = true;
    end

    %check if point's y coordinate is between end point's y coordinates
    if((point(2) > el_1(2) && point(2) < el_2(2)) || (point(2) < el_1(2) && point(2) > el_2(2)))
        flagy = true;
    end

    %check if point's z coordinate is between z coordinates of end points
    if((point(3) >  el_1(3) && point(3) < el_2(3)) || (point(3) < el_1(3) && point(3) > el_2(3)))
        flagz = true;
    end

    %check if point's x coordinate is  coincident with x coordinate of an end
    %point
    if(abs(point(1) - el_1(1)) < SMALL|| abs(point(1) - el_2(1)) < SMALL)
        flagx = true;
    end

    %check if point's y coordinate is  coincident with y coordinate of an end
    %point
    if(abs(point(2) - el_1(2)) < SMALL || abs(point(2) - el_2(2)) < SMALL)
        flagy = true;
    end

    %check if point's z coordinate is  coincident with z coordinate of an end
    %point
    if(abs(point(3) - el_1(3)) < SMALL|| abs(point(3) - el_2(3)) < SMALL)
        flagz = true;
    end

    %set flag to true or false
    if(flagx && flagy && flagz)
        flag = true;
    end


end
