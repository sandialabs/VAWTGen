function [componentList] = insertJunctionNodes(junctionList,componentList)
%insertJunctionNodes inserts junction nodes into a component discretization
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   [componentList] = insertJunctionNodes(componentJunctionList,...
%                     componentList)
%                    
%   This function inserts a junction node into a component discretization.
%
%      input:
%      componentJunctionList = list of object containing junction data
%      componentList         = list of objects containing component
%                              information
% 
%      output:
%      componentList         = list of objects containing modified 
%                              component information

numComponents = length(componentList); %get number of components
[componentJunctionList] = getJunctionNodalData(junctionList,numComponents); %determine which junctions require node insertion

[~,len]=size(componentJunctionList); %get number of nodes to be inserted

for i=1:len %loop over number of nodes to be inserted
   if(~isempty(componentJunctionList{i}))
       for j=1:length(componentJunctionList{i}.el) %loop over number of elements to have node inserted
           point = componentJunctionList{i}.pt(j,:); %get coordinate of junction
           el = componentJunctionList{i}.el(j); %get element junction is associated with
           [~,xlen]=size(componentList{i}.x'); %get number of nodes in component

           %update component section coordinates for inserted node
           componentList{i}.x = [componentList{i}.x(1:el);point(1);componentList{i}.x(el+1:xlen)];
           componentList{i}.y = [componentList{i}.y(1:el);point(2);componentList{i}.y(el+1:xlen)];
           componentList{i}.z = [componentList{i}.z(1:el);point(3);componentList{i}.z(el+1:xlen)];

           %modify component properties for inserted node
           [componentList{i}.props] = insertNodeIntoElementProps(componentList{i}.props,el,componentJunctionList{i}.frac(j));

           %update element insert numberings..
           for k = j+1:length(componentJunctionList{i}.el)
               componentJunctionList{i}.el(k) = componentJunctionList{i}.el(k)+1;
           end
       end
   end
end


end

function [prop] = insertNodeIntoElementProps(componentProps,el,frac)
%This function inserts a node into an existing discretization of a
%component and modifies the properties by interpolating between nodes where
%the new node is inserted.  componentProps contains a list of spanwise
%properties for the component, el denotes the element that will have a node
%inserted, and frac denotes the fraction along an element length the new
%node will be inserted at.

    len = length(componentProps.BlFract); %number of stations

    %calculate spanwise fraction along component new node will be inserted
    %at
    temp = componentProps.BlFract(el)+frac*(componentProps.BlFract(el+1)-componentProps.BlFract(el));
    
    %interpolate component properties at new node location
    currentBlFract=interp1(componentProps.BlFract,componentProps.BlFract,temp,'linear');
    AeroCent = interp1(componentProps.BlFract,componentProps.AeroCent,currentBlFract,'linear');
    StrcTwst = interp1(componentProps.BlFract,componentProps.StrcTwst,currentBlFract,'linear');
    BMassDen = interp1(componentProps.BlFract,componentProps.BMassDen,currentBlFract,'linear');
    FlpStff = interp1(componentProps.BlFract,componentProps.FlpStff,currentBlFract,'linear');
    EdgStff = interp1(componentProps.BlFract,componentProps.EdgStff,currentBlFract,'linear');
    GJStff = interp1(componentProps.BlFract,componentProps.GJStff,currentBlFract,'linear');
    EAStff = interp1(componentProps.BlFract,componentProps.EAStff,currentBlFract,'linear');
    Alpha = interp1(componentProps.BlFract,componentProps.Alpha,currentBlFract,'linear');
    FlpIner = interp1(componentProps.BlFract,componentProps.FlpIner,currentBlFract,'linear');
    EdgIner = interp1(componentProps.BlFract,componentProps.EdgIner,currentBlFract,'linear');
    PrecrvRef = interp1(componentProps.BlFract,componentProps.PrecrvRef,currentBlFract,'linear');
    PreswpRef = interp1(componentProps.BlFract,componentProps.PreswpRef,currentBlFract,'linear');
    FlpcgOf = interp1(componentProps.BlFract,componentProps.FlpcgOf,currentBlFract,'linear');
    EdgcgOf = interp1(componentProps.BlFract,componentProps.EdgcgOf,currentBlFract,'linear');
    FlpEAOf = interp1(componentProps.BlFract,componentProps.FlpEAOf,currentBlFract,'linear');
    EdgEAOf = interp1(componentProps.BlFract,componentProps.EdgEAOf,currentBlFract,'linear');
    
    %insert properties associated with new node into component spanwise
    %property array
    prop.BlFract  =[componentProps.BlFract(1:el); currentBlFract ;componentProps.BlFract(el+1:len)];
    prop.AeroCent =[componentProps.AeroCent(1:el); AeroCent ;componentProps.AeroCent(el+1:len)];
    prop.StrcTwst =[componentProps.StrcTwst(1:el); StrcTwst ;componentProps.StrcTwst(el+1:len)];
    prop.BMassDen =[componentProps.BMassDen(1:el); BMassDen ;componentProps.BMassDen(el+1:len)];
    prop.FlpStff =[componentProps.FlpStff(1:el); FlpStff ;componentProps.FlpStff(el+1:len)];
    prop.EdgStff =[componentProps.EdgStff(1:el); EdgStff ;componentProps.EdgStff(el+1:len)];
    prop.GJStff  =[componentProps.EdgStff(1:el); GJStff ;componentProps.GJStff(el+1:len)];
    prop.EAStff  =[componentProps.EAStff(1:el); EAStff ;componentProps.EAStff(el+1:len)];
    prop.Alpha   =[componentProps.Alpha(1:el); Alpha ;componentProps.Alpha(el+1:len)];
    prop.FlpIner =[componentProps.FlpIner(1:el); FlpIner ;componentProps.FlpIner(el+1:len)];
    prop.EdgIner =[componentProps.EdgIner(1:el); EdgIner ;componentProps.EdgIner(el+1:len)];
    prop.PrecrvRef=[componentProps.PrecrvRef(1:el); PrecrvRef ;componentProps.PrecrvRef(el+1:len)];
    prop.PreswpRef=[componentProps.PreswpRef(1:el); PreswpRef ;componentProps.PreswpRef(el+1:len)];
    prop.FlpcgOf=[componentProps.FlpcgOf(1:el); FlpcgOf ;componentProps.FlpcgOf(el+1:len)];
    prop.EdgcgOf=[componentProps.EdgcgOf(1:el); EdgcgOf ;componentProps.EdgcgOf(el+1:len)];
    prop.FlpEAOf=[componentProps.FlpEAOf(1:el); FlpEAOf ;componentProps.FlpEAOf(el+1:len)];
    prop.EdgEAOf=[componentProps.EdgEAOf(1:el); EdgEAOf ;componentProps.EdgEAOf(el+1:len)];
    

end

