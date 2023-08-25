function blade = readFastBladeFile(input_file)
%readFastBladeFile  Read a FAST blade input file.
% **********************************************************************
% *                   Part of SNLVAWTGen                               *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   blade = readFastBlade('input_file_name') 
%   Returns a structure containing the data in a FAST blade input file.

if ~exist('input_file','var')
    [fn pn] = uigetfile( ...
        {'*.dat','Blade/Tower data (*.dat)'; ...
        '*.*','All files (*.*)'});
    if isequal(fn,0)
        return
    else
        input_file = [pn, fn];
    end
end

fid=fopen(input_file);
if (fid == -1)
    error('Could not open input "%s"\n',input_file);
    return
end
blade.ffn = input_file;


% begin reading input file
%read in first few lines of code
readLines(18,fid);
PropTable           = textscan(fid,repmat('%f ',1,17));
blade.prop.BlFract   = PropTable{ 1};
blade.prop.AeroCent  = PropTable{ 2};
blade.prop.StrcTwst  = PropTable{ 3};
blade.prop.BMassDen  = PropTable{ 4};
blade.prop.FlpStff   = PropTable{ 5};
blade.prop.EdgStff   = PropTable{ 6};
blade.prop.GJStff    = PropTable{ 7};
blade.prop.EAStff    = PropTable{ 8};
blade.prop.Alpha     = PropTable{ 9};
blade.prop.FlpIner   = PropTable{10};
blade.prop.EdgIner   = PropTable{11};
blade.prop.PrecrvRef = PropTable{12};
blade.prop.PreswpRef = PropTable{13};
blade.prop.FlpcgOf   = PropTable{14};
blade.prop.EdgcgOf   = PropTable{15};
blade.prop.FlpEAOf   = PropTable{16};
blade.prop.EdgEAOf   = PropTable{17};

fclose(fid);
end

function readLines(numLinesToRead,fid)
    for i=1:numLinesToRead
        fgetl(fid);
    end
end
