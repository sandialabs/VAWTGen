function writeVAWTGenInputFile(inputData,fn)
    fid = fopen(fn,'w');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.towerHeight);
    fprintf(fid,':tower height\n');
    
    fprintf(fid,'%s\t\t\t\t',inputData.towerFn);
    fprintf(fid,':tower data file\n');
    
    fprintf(fid,'%s\t\t\t\t',inputData.towerIpt);
    fprintf(fid,':tower aero file\n');
    
    fprintf(fid,'%i\t\t\t\t',inputData.numTowerSubdivisions);
    fprintf(fid,':number of tower subdivisions\n');
    
    fprintf(fid,'%i\t\t\t\t',inputData.numBlades);
    fprintf(fid,':number of blades\n');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.bladeLength);
    fprintf(fid,':blade length\n');
    
    fprintf(fid,'%s\t\t\t\t',inputData.bladeFn);
    fprintf(fid,':blade data file\n');
    
    fprintf(fid,'%s\t\t\t\t',inputData.bladeIpt);
    fprintf(fid,':blade aero file\n');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.rootElevation);
    fprintf(fid,':blade root elevation\n');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.rootRadialOffset);
    fprintf(fid,':blade radial offset\n');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.bladeTheta);
    fprintf(fid,':blade theta angle\n');
    
    fprintf(fid,'%7.3f\t\t\t\t',inputData.bladeSweep);
    fprintf(fid,':blade sweep angle\n');
    
    fprintf(fid,'%i\t\t\t\t',inputData.numBladeSubdivisions);
    fprintf(fid,':number of blade subdivisions\n');
    
    fprintf(fid,'%i\t\t\t\t',inputData.numStruts);
    fprintf(fid,':number of struts\n');
    
    for i=1:inputData.numStruts
        
        fprintf(fid,'%s\t\t\t\t',inputData.strutFn{i});
        fprintf(fid,':strut data file\n');
        
        fprintf(fid,'%s\t\t\t\t',inputData.strutIpt{i});
        fprintf(fid,':strut aero file\n');

        fprintf(fid,'%7.3f\t%7.3f\t\t\t\t',inputData.strutParams(i,:));
        fprintf(fid,':strut parameters\n');
        
        fprintf(fid,'%7.3f\t\t\t\t',inputData.strutTtoC(i));
        fprintf(fid,':strut thickness to chord ratio\n');
        
        fprintf(fid,'%i\t\t\t\t',inputData.numStrutSubdivisions(i));
        fprintf(fid,':num subdivisions per strut\n');
       
    end
    
    fclose(fid);
end

