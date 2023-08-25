function [ componentList ] = InitializeAndCreateComponents(model)

hasTower = true; %initialize boolean flag to denote model has tower

%unpack tower and blade filenames
towerFn = model.towerFn;
towerAd = model.towerAd;
bladeFn = model.bladeFn;
bladeAd = model.bladeAd;

%unpack tower height and blade length
towerHt = model.towerHt;
bladeLn = model.bladeLn;

%if tower height is <= 0 sets hasTower flag to false
if(towerHt<=0)
    hasTower = false;
end

%unpack number of blades, number of struts per blade
numBlades = model.numBlades;
numStruts = model.numStrutsPerBlade*numBlades;
numStrutsPerBlade = model.numStrutsPerBlade;

%unpack number of struts per blade (if applicable)
if(numStrutsPerBlade > 0)
    strutFn = model.strutFn;
    strutAd = model.strutAd;
    strutParam = model.strutParam;
    strutTtoC = model.strutTtoC;
end

%unpack blade orientation and offset
bladeTheta = model.bladeTheta;
bladeSweepAng = model.bladeSweepAng;
rotorRadius = model.rotorRadius;
bladeElevation = model.bladeElevation;

%calculate azimuth spacing of blades
delPsi = 360/numBlades;

%set number of components
if(hasTower)
    numComponents = 1 + numBlades + numStruts;
else
    numComponents = numBlades + numStruts;
end

compIndex = 1;
if(~hasTower)
    compIndex = 2;
end
for i=1:numComponents
   if(compIndex==1) %tower initialization
       componentList{i}.fnname = towerFn;
       componentList{i}.adname = towerAd;
       componentList{i}.length = towerHt;
       
       componentList{i}.Psi = 0.0;
       componentList{i}.Theta = -90.0;
       componentList{i}.SweepAng = 0.0;
       
       componentList{i}.xOffset = 0.0;
       componentList{i}.yOffset = 0.0;
       componentList{i}.zOffset = 0.0;
       
       componentList{i}.numDiv = model.towerNumDiv;
       
       componentList{i}.type = 'T';
       
       data = readFastBladeFile(componentList{i}.fnname);
       %do not consider pre curve or pre sweep in tower
       data.prop.PrecrvRef = data.prop.PrecrvRef*0;
       data.prop.PreswpRef = data.prop.PreswpRef*0;
       componentList{i}.props = data.prop;
       [componentList{i}.props] = refineComponent(componentList{i}.props,componentList{i}.numDiv);
       
       aeroData = readFastIpt(componentList{i}.adname);
       componentList{i}.aeroR = aeroData.RNodes;
       componentList{i}.airfoilIndex = aeroData.NFoil;
       componentList{i}.airfoilFn = aeroData.FoilNm;
       
   end
   
   if(compIndex>1 && compIndex<=(numBlades+1)) %blades initialization
       componentList{i}.fnname = bladeFn;
       componentList{i}.adname = bladeAd;
       componentList{i}.length = bladeLn;
       Psi = (compIndex-2)*delPsi;  %Psi is azimuth position (equal rotor spacing)
       componentList{i}.Psi = Psi;
       componentList{i}.Theta = bladeTheta;
       componentList{i}.SweepAng = bladeSweepAng;
       
       componentList{i}.xOffset = rotorRadius*cos(Psi*pi/180 + pi); %ensures blade 1 is at 180 degrees azimuth, blade numbered in counter-clockwise order
       componentList{i}.yOffset = rotorRadius*sin(Psi*pi/180 + pi);
       componentList{i}.zOffset = bladeElevation;
       
       componentList{i}.numDiv = model.bladeNumDiv;
       
       componentList{i}.type = 'B';
       
       data = readFastBladeFile(componentList{i}.fnname);
       data.prop.PrecrvRef = data.prop.PrecrvRef;
       data.prop.PreswpRef = data.prop.PreswpRef;
       
       maxprecrv = max(data.prop.PrecrvRef);
       maxpreswp = max(data.prop.PreswpRef);
      %make precrv the dominant blade curvature
       if(maxpreswp > maxprecrv)
           disp('WARNING: Specified pre-sweep is more cominant than pre-curve.');
           disp('For Darrieus type configuration, pre-curve  should be used to shape the blade profile.');
       end
       
        componentList{i}.props = data.prop;
       [componentList{i}.props] = refineComponent(componentList{i}.props,componentList{i}.numDiv);
       
       aeroData = readFastIpt(componentList{i}.adname);
       componentList{i}.aeroR = aeroData.RNodes;
       componentList{i}.aeroChord = aeroData.Chord;
       componentList{i}.airfoilIndex = aeroData.NFoil;
       componentList{i}.airfoilFn = aeroData.FoilNm;
       componentList{i}.aeroTwist = aeroData.AeroTwst;
       
       %allows for a point other than blade root to be offset.
        stationLoc = componentList{i}.props.BlFract .* bladeLn;
        lenb1 = length(stationLoc); %get number of nodes for component
        B1 = zeros(lenb1,1); %initialize body frame coordinate vectors
        B2 = B1;
        B3 = B1;
        for k1=1:lenb1   %loop over number of nodes
            B1(k1) = stationLoc(k1);   %specify local coordinates of component
            B2(k1) = componentList{i}.props.EdgEAOf(k1) + componentList{i}.props.PreswpRef(k1);
            B3(k1) = componentList{i}.props.FlpEAOf(k1) + componentList{i}.props.PrecrvRef(k1);
        end
        rSpanOffset = 0.0; %this could be fed as an input parameter in the future if an arbitrary point on the blade (other than the root) needs to be offset
        B1correction = interp1(B1,B1,rSpanOffset*bladeLn,'linear');
        B2correction = interp1(B1,B2,rSpanOffset*bladeLn,'linear');
        B3correction = interp1(B1,B3,rSpanOffset*bladeLn,'linear');
        [H1correction,H2correction,H3correction] = rigidBodyRotation(B1correction,B2correction,B3correction,[Psi,bladeTheta,bladeSweepAng],[3,2,3]);

        offsetCorrection = [H1correction;H2correction;H3correction];

        %offset comonent from frame origin by desired position(offset) vector
        componentList{i}.xOffset = componentList{i}.xOffset - offsetCorrection(1);
        componentList{i}.yOffset = componentList{i}.yOffset - offsetCorrection(2);
        componentList{i}.zOffset = componentList{i}.zOffset - offsetCorrection(3);
       
       
       %load in LCSvals
       if(fopen('LCSvals.mat','r')==-1)
           componentList{i}.LCS = ones(length(componentList{i}.aeroR),1)*2*pi; %if LCSvals does not exist, default LCSvals to 2*pi
       else
           load LCSVals;
           for k=1:length(componentList{i}.aeroR)
              lcsIndex = componentList{i}.airfoilIndex(k);
              componentList{i}.LCS(k) = LCSVals(lcsIndex);
           end
           clear LCSVals
       end
           
   end
   
   compIndex = compIndex + 1;
end
   %strut initializations
   localStrutNum = 1;
   for k=1:numStrutsPerBlade
     for m=1:numBlades
      i = numBlades+1+localStrutNum;

       componentList{i}.fnname = strutFn(k,:); %strut .dat file
       componentList{i}.adname = strutAd(k,:); %strut .ipt file
       
       %strut calculations .........................................
       blade = readFastBladeFile(bladeFn); 
       
       %define strut junction point on blade in blade frame
       StrutEndB2 =  interp1(blade.prop.BlFract,blade.prop.EdgEAOf,strutParam(k,2),'linear')...
                     +interp1(blade.prop.BlFract,blade.prop.PreswpRef,strutParam(k,2),'linear');
       StrutEndB1 = strutParam(k,2)*bladeLn;
       StrutEndB3 = interp1(blade.prop.BlFract,blade.prop.FlpEAOf,strutParam(k,2),'linear')...
                    +interp1(blade.prop.BlFract,blade.prop.PrecrvRef,strutParam(k,2),'linear');
              
       %rotate from blade frame to hub frame, apply offsets and construct
       %"strutVec"along strut axis.
       Psi1=componentList{m+1}.Psi;
       Theta1=componentList{m+1}.Theta;
       SweepAng1=componentList{m+1}.SweepAng;
       [StrutEndH1,StrutEndH2,StrutEndH3] = rigidRotationBlade(StrutEndB1,StrutEndB2,StrutEndB3,Psi1,Theta1,SweepAng1);
       strutVec=[StrutEndH1+componentList{m+1}.xOffset,StrutEndH2+componentList{m+1}.yOffset,StrutEndH3+componentList{m+1}.zOffset-towerHt*(strutParam(k,1))];
       
       %calculate strutVec Psi and Theta angles and strut length
       [PsiStrut,ThetaStrut] = calculatePsiTheta(strutVec);

       strutLn = norm(strutVec,2);
      
      %assign strut orientation
      componentList{i}.Psi = PsiStrut;
      componentList{i}.Theta = ThetaStrut;
      componentList{i}.SweepAng = 0.0;
       
            %strut calculations .........................................
       
            componentList{i}.length = strutLn;
            
            componentList{i}.xOffset = 0.0;
            componentList{i}.yOffset = 0.0;
            componentList{i}.zOffset = towerHt*strutParam(k,1);
            
            componentList{i}.numDiv = model.strutNumDiv(k);
       
            componentList{i}.type = 'S';
            componentList{i}.bladeIndex = m;
            componentList{i}.TtoC = strutTtoC(k);
            
            
            data = readFastBladeFile(componentList{i}.fnname);
            %do not consider pre curve or pre sweep in struts
            data.prop.PrecrvRef = data.prop.PrecrvRef*0;
            data.prop.PreswpRef = data.prop.PreswpRef*0;
            componentList{i}.props = data.prop;
            [componentList{i}.props] = refineComponent(componentList{i}.props,componentList{i}.numDiv);
            
            aeroData = readFastIpt(componentList{i}.adname);
            componentList{i}.aeroR = aeroData.RNodes;
            componentList{i}.aeroChord = aeroData.Chord;
            componentList{i}.airfoilIndex = aeroData.NFoil;
            componentList{i}.airfoilFn = aeroData.FoilNm;
            componentList{i}.aeroTwist = aeroData.AeroTwst;
       
            localStrutNum = localStrutNum+1;
     end
           
    end
   


%create components
for i=1:numComponents
    [componentList{i}] = createComponent(componentList{i});
end

end


function [H1,H2,H3] = rigidRotationBlade(B1,B2,B3,Psi,Theta,SweepAng)
        %peform rotation about h3 axis
        Psi = Psi*pi/180.0;
        Theta = Theta*pi/180.0;
        SweepAng = SweepAng*pi/180.0;
        
        M3 = [cos(Psi) sin(Psi) 0; -sin(Psi) cos(Psi) 0; 0 0 1];
        M2 = [cos(Theta) 0 -sin(Theta);0 1 0; sin(Theta),0,cos(Theta)];
        M3f = [cos(SweepAng) sin(SweepAng) 0; -sin(SweepAng) cos(SweepAng) 0; 0 0 1];
        
        C=(M3f*M2*M3)';
    
        H1 = C(1,1).*B1 + C(1,2).* B2 + C(1,3).*B3;
        H2 = C(2,1).*B1 + C(2,2).* B2 + C(2,3).*B3;
        H3 = C(3,1).*B1 + C(3,2).* B2 + C(3,3).*B3;
end

function [newprops] = refineComponent(oldProps,numDiv)
%This function furhter refines a component if desired. The object oldProps 
%contains the original component properties, and numDiv is an integer
%denoting how many discretizations should occur per element. The object
%newprops contains properties with the new discretization.

    len = length(oldProps.BlFract);
    tempProp=oldProps;
    insertedEl = 0; 
    for i=1:len-1
        delfrac = 1/numDiv;
        frac=[];
        for k=1:numDiv-1
            frac(k) = k*delfrac;
        end
        if(~isempty(frac))
            tempProp = insertNodeIntoElementProps(tempProp,i+insertedEl,frac);
            insertedEl = insertedEl + numDiv-1;
        end
        
    end
    
    newprops=tempProp;
end

function [prop] = insertNodeIntoElementProps(componentProps,el,frac)
%This function inserts a node into an existing discretization of a
%component and modifies the properties by interpolating between nodes where
%the new node is inserted.  componentProps contains a list of spanwise
%properties for the component, el denotes the element that will have a node
%inserted, and frac denotes the fraction along an element length the new
%node will be inserted at.

    len = length(componentProps.BlFract);
    
    temp = componentProps.BlFract(el)+frac.*(componentProps.BlFract(el+1)-componentProps.BlFract(el));
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
     
    prop.BlFract  =[componentProps.BlFract(1:el); currentBlFract' ;componentProps.BlFract(el+1:len)];
    prop.AeroCent =[componentProps.AeroCent(1:el); AeroCent' ;componentProps.AeroCent(el+1:len)];
    prop.StrcTwst =[componentProps.StrcTwst(1:el); StrcTwst' ;componentProps.StrcTwst(el+1:len)];
    prop.BMassDen =[componentProps.BMassDen(1:el); BMassDen' ;componentProps.BMassDen(el+1:len)];
    prop.FlpStff =[componentProps.FlpStff(1:el); FlpStff' ;componentProps.FlpStff(el+1:len)];
    prop.EdgStff =[componentProps.EdgStff(1:el); EdgStff' ;componentProps.EdgStff(el+1:len)];
    prop.GJStff  =[componentProps.EdgStff(1:el); GJStff' ;componentProps.GJStff(el+1:len)];
    prop.EAStff  =[componentProps.EAStff(1:el); EAStff' ;componentProps.EAStff(el+1:len)];
    prop.Alpha   =[componentProps.Alpha(1:el); Alpha' ;componentProps.Alpha(el+1:len)];
    prop.FlpIner =[componentProps.FlpIner(1:el); FlpIner' ;componentProps.FlpIner(el+1:len)];
    prop.EdgIner =[componentProps.EdgIner(1:el); EdgIner' ;componentProps.EdgIner(el+1:len)];
    prop.PrecrvRef=[componentProps.PrecrvRef(1:el); PrecrvRef' ;componentProps.PrecrvRef(el+1:len)];
    prop.PreswpRef=[componentProps.PreswpRef(1:el); PreswpRef' ;componentProps.PreswpRef(el+1:len)];
    prop.FlpcgOf=[componentProps.FlpcgOf(1:el); FlpcgOf' ;componentProps.FlpcgOf(el+1:len)];
    prop.EdgcgOf=[componentProps.EdgcgOf(1:el); EdgcgOf' ;componentProps.EdgcgOf(el+1:len)];
    prop.FlpEAOf=[componentProps.FlpEAOf(1:el); FlpEAOf' ;componentProps.FlpEAOf(el+1:len)];
    prop.EdgEAOf=[componentProps.EdgEAOf(1:el); EdgEAOf' ;componentProps.EdgEAOf(el+1:len)];
    

end
