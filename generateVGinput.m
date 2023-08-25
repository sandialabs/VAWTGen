function generateVGinput(towerHeight,towerFn,towerIpt,bladeLength,bladeFn,bladeIpt,numberOfBlades,numStruts,strutParams,strutIpt,vgInputFn,doEndCorrection,strutSubDiv)

    if(doEndCorrection)
        blade = readFastBlade(bladeFn);
        blade.prop.PrecrvRef([1,end]) = 0.0;
        blade.prop.PreswpRef([1,end]) = 0.0;
        blade.prop.FlpEAOf([1,end]) = 0.0;
        blade.prop.EdgEAOf([1,end]) = 0.0;
        writeBladeDatFile(blade,bladeFn);
    end
    
    %CREATE STRUT PARAMETERS
    blade = readFastBlade(bladeFn);
    bladeSpan = blade.prop.BlFract;
    for i=1:numStruts
       strutProps(i,1) = interp1(bladeSpan,blade.prop.BlFract,strutParams(i,2)); 
       strutProps(i,2) = interp1(bladeSpan,blade.prop.AeroCent,strutParams(i,2)); 
       strutProps(i,3) = interp1(bladeSpan,blade.prop.StrcTwst,strutParams(i,2)); 
       strutProps(i,4) = interp1(bladeSpan,blade.prop.BMassDen,strutParams(i,2)); 
       strutProps(i,5) = interp1(bladeSpan,blade.prop.FlpStff,strutParams(i,2)); 
       strutProps(i,6) = interp1(bladeSpan,blade.prop.EdgStff,strutParams(i,2)); 
       strutProps(i,7) = interp1(bladeSpan,blade.prop.GJStff,strutParams(i,2)); 
       strutProps(i,8) = interp1(bladeSpan,blade.prop.EAStff,strutParams(i,2));
       strutProps(i,9) = interp1(bladeSpan,blade.prop.Alpha,strutParams(i,2)); 
       strutProps(i,10) = interp1(bladeSpan,blade.prop.FlpIner,strutParams(i,2)); 
       strutProps(i,11) = interp1(bladeSpan,blade.prop.EdgIner,strutParams(i,2)); 
       strutProps(i,12) = interp1(bladeSpan,blade.prop.PrecrvRef,strutParams(i,2))*0; 
       strutProps(i,13) = interp1(bladeSpan,blade.prop.PreswpRef,strutParams(i,2))*0;
       strutProps(i,14) = interp1(bladeSpan,blade.prop.FlpcgOf,strutParams(i,2))*0;
       strutProps(i,15) = interp1(bladeSpan,blade.prop.EdgcgOf,strutParams(i,2))*0;
       strutProps(i,16) = interp1(bladeSpan,blade.prop.FlpEAOf,strutParams(i,2))*0;
       strutProps(i,17) = interp1(bladeSpan,blade.prop.EdgEAOf,strutParams(i,2))*0;
    end

    numSectionsPerStrut = 3;

    for i=1:numStruts
        strutFn{i} = ['strut',num2str(i),'.dat'];
        strut = blade;
        strut.NBlInpSt = numSectionsPerStrut;
        strut.prop.BlFract =  linspace(0,1,numSectionsPerStrut)';
        strut.prop.AeroCent = ones(numSectionsPerStrut,1)*strutProps(i,2);
        strut.prop.StrcTwst = ones(numSectionsPerStrut,1)*strutProps(i,3);
        strut.prop.BMassDen = ones(numSectionsPerStrut,1)*strutProps(i,4);
        strut.prop.FlpStff  = ones(numSectionsPerStrut,1)*strutProps(i,5);
        strut.prop.EdgStff  = ones(numSectionsPerStrut,1)*strutProps(i,6);
        strut.prop.GJStff  = ones(numSectionsPerStrut,1)*strutProps(i,7);
        strut.prop.EAStff  = ones(numSectionsPerStrut,1)*strutProps(i,8);
        strut.prop.Alpha  = ones(numSectionsPerStrut,1)*strutProps(i,9);
        strut.prop.FlpIner  = ones(numSectionsPerStrut,1)*strutProps(i,10);
        strut.prop.EdgIner  = ones(numSectionsPerStrut,1)*strutProps(i,11);
        strut.prop.PrecrvRef  = ones(numSectionsPerStrut,1)*strutProps(i,12);
        strut.prop.PreswpRef  = ones(numSectionsPerStrut,1)*strutProps(i,13);
        strut.prop.FlpcgOf  = ones(numSectionsPerStrut,1)*strutProps(i,14);
        strut.prop.EdgcgOf  = ones(numSectionsPerStrut,1)*strutProps(i,15);
        strut.prop.FlpEAOf  = ones(numSectionsPerStrut,1)*strutProps(i,16);
        strut.prop.EdgEAOf  = ones(numSectionsPerStrut,1)*strutProps(i,17);
        strutArray(i) = strut;

        writeBladeDatFile(strutArray(i),strutFn{i});
    end

    vgInput.towerHeight = towerHeight;
    vgInput.towerFn = towerFn;
    vgInput.towerIpt = towerIpt;
    vgInput.numTowerSubdivisions = 1;
    vgInput.numBlades = numberOfBlades;
    vgInput.bladeLength = bladeLength;
    vgInput.bladeFn = bladeFn;
    vgInput.bladeIpt = bladeIpt;

    vgInput.rootElevation = 0.0;
    vgInput.rootRadialOffset = 0.0;
    vgInput.bladeTheta = -90.0;
    vgInput.bladeSweep = 0.0;
    vgInput.numBladeSubdivisions = 1;
    vgInput.numStruts = numStruts;

    vgInput.strutFn = strutFn;
    vgInput.strutIpt = {strutIpt,strutIpt};
    vgInput.strutParams = strutParams;
    vgInput.strutTtoC = [0.15;0.15];
    vgInput.numStrutSubdivisions = strutSubDiv;

    writeVAWTGenInputFile(vgInput,vgInputFn);

end

