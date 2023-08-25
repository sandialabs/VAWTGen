function writeBladeDatFile(blade,fn)

fid = fopen(fn,'w');
fprintf(fid,'--------------------------------------------------------------------------------\n','%s');
fprintf(fid,'---------------------- FAST INDIVIDUAL BLADE FILE ------------------------------\n','%s');
fprintf(fid,blade.title{1},'%s'); fprintf(fid,'\n');
fprintf(fid,'---------------------- BLADE PARAMETERS ----------------------------------------\n','%s');
fprintf(fid,'\t%i',blade.NBlInpSt);
fprintf(fid,'\t\t NBlInpSt    - Number of blade input stations (-)\n\t','%s');
fprintf(fid,blade.CalcBMode,'%s'); fprintf(fid,'\tCalcBMode   - Calculate blade mode shapes internally {T: ignore mode shapes from below, F: use mode shapes from below} [CURRENTLY IGNORED] (flag)');fprintf(fid,'\n');
fprintf(fid,'\t %4.3f',blade.BldFlDmp(1)); fprintf(fid,'\t\tBldFlDmp(1) - Blade flap mode #1 structural damping in percent of critical (%%)','%s');fprintf(fid,'\n');
fprintf(fid,'\t %4.3f',blade.BldFlDmp(2)); fprintf(fid,'\t\tBldEdDmp(1) - Blade flap mode #2 structural damping in percent of critical (%%)','%s');fprintf(fid,'\n');
fprintf(fid,'\t %4.3f',blade.BldEdDmp); fprintf(fid,'\t\tBldEdDmp(1) - Blade edge mode #1 structural damping in percent of critical (%%)','%s');fprintf(fid,'\n');
fprintf(fid,'---------------------- BLADE ADJUSTMENT FACTORS --------------------------------\n','%s');
fprintf(fid,'\t%3.2f',blade.FlStTunr(1));
fprintf(fid,'\t FlStTunr(1) - Blade flapwise modal stiffness tuner, 1st mode (-)\n','%s');
fprintf(fid,'\t%3.2f',blade.FlStTunr(1));
fprintf(fid,'\t FlStTunr(2) - Blade flapwise modal stiffness tuner, 2nd mode (-)\n','%s');
fprintf(fid,'\t%3.2f',blade.AdjBlMs(1));
fprintf(fid,'\t AdjBlMs     - Factor to adjust blade mass density (-)\n','%s');
fprintf(fid,'\t%3.2f',blade.AdjFlSt(1));
fprintf(fid,'\t AdjFlSt     - Factor to adjust blade flap stiffness (-)\n','%s');
fprintf(fid,'\t%3.2f',blade.AdjEdSt(1));
fprintf(fid,'\t AdjEdSt     - Factor to adjust blade edge stiffness (-)\n','%s');
fprintf(fid,'---------------------- DISTRIBUTED BLADE PROPERTIES ----------------------------\n','%s');
fprintf(fid,'BlFract  AeroCent  StrcTwst  BMassDen  FlpStff      EdgStff      GJStff       EAStff       Alpha  FlpIner  EdgIner  PrecrvRef  PreswpRef  FlpcgOf  EdgcgOf  FlpEAOf  EdgEAOf\n');
fprintf(fid,'(-)      (-)       (deg)     (kg/m)    (Nm^2)       (Nm^2)       (Nm^2)       (N)            (-)  (kg m)   (kg m)   (m)        (m)        (m)      (m)      (m)      (m)\n');

printLineBladeProps(fid,blade.prop);

fprintf(fid,'---------------------- BLADE MODE SHAPES ---------------------------------------\n','%s');
fprintf(fid,'\t%5.4f\t',blade.BldFl1Sh(2));fprintf(fid,'\tBldFl1Sh(2) - Flap mode 1, coeff of x^2\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl1Sh(3));fprintf(fid,'\tBldFl1Sh(3) -            , coeff of x^3\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl1Sh(4));fprintf(fid,'\tBldFl1Sh(4) -            , coeff of x^4\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl1Sh(5));fprintf(fid,'\tBldFl1Sh(5) -            , coeff of x^5\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl1Sh(6));fprintf(fid,'\tBldFl1Sh(6) -            , coeff of x^6\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl2Sh(2));fprintf(fid,'\tBldFl2Sh(2) - Flap mode 2, coeff of x^2\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl2Sh(3));fprintf(fid,'\tBldFl2Sh(3) -            , coeff of x^3\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl2Sh(4));fprintf(fid,'\tBldFl2Sh(4) -            , coeff of x^4\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl2Sh(5));fprintf(fid,'\tBldFl2Sh(5) -            , coeff of x^5\n');
fprintf(fid,'\t%5.4f\t',blade.BldFl2Sh(6));fprintf(fid,'\tBldFl2Sh(6) -            , coeff of x^6\n');
fprintf(fid,'\t%5.4f\t',blade.BldEdgSh(2));fprintf(fid,'\tBldEdgSh(2) - Edge mode 1, coeff of x^2\n');
fprintf(fid,'\t%5.4f\t',blade.BldEdgSh(3));fprintf(fid,'\tBldEdgSh(3) -            , coeff of x^3\n');
fprintf(fid,'\t%5.4f\t',blade.BldEdgSh(4));fprintf(fid,'\tBldEdgSh(4) -            , coeff of x^4\n');
fprintf(fid,'\t%5.4f\t',blade.BldEdgSh(5));fprintf(fid,'\tBldEdgSh(5) -            , coeff of x^5\n');
fprintf(fid,'\t%5.4f\t',blade.BldEdgSh(6));fprintf(fid,'\tBldEdgSh(6) -            , coeff of x^6\n');
fclose(fid);
end

function printLineBladeProps(fid,prop)
    for i=1:length(prop.BlFract)
        fprintf(fid,'%6.5f\t',prop.BlFract(i));
        fprintf(fid,'%4.3f\t',prop.AeroCent(i));
        fprintf(fid,'%4.3f\t',prop.StrcTwst(i));
        fprintf(fid,'%7.3f\t',prop.BMassDen(i));
        fprintf(fid,'%6.5e\t',prop.FlpStff(i));
        fprintf(fid,'%6.5e\t',prop.EdgStff(i));
        fprintf(fid,'%6.5e\t',prop.GJStff(i));
        fprintf(fid,'%6.5e\t',prop.EAStff(i));
        fprintf(fid,'%2.1f\t',prop.Alpha(i));
        fprintf(fid,'%6.3f\t',prop.FlpIner(i));
        fprintf(fid,'%6.3f\t',prop.EdgIner(i));
        fprintf(fid,'%5.4f\t',prop.PrecrvRef(i));
        fprintf(fid,'%5.4f\t',prop.PreswpRef(i));
        fprintf(fid,'%4.3f\t',prop.FlpcgOf(i));
        fprintf(fid,'%4.3f\t',prop.EdgcgOf(i));
        fprintf(fid,'%4.3f\t',prop.FlpEAOf(i));
        fprintf(fid,'%4.3f',prop.EdgEAOf(i));
        fprintf(fid,'\n');
    end
end

