function ipt = readFastIpt(input_file)
%readFastIpt Read a FAST IPT input file.
% **********************************************************************
% *                   Part of SNL VAWTGen                              *
% * Developed by Sandia National Laboratories Wind Energy Technologies *
% *             See license.txt for disclaimer information             *
% **********************************************************************
%   ipt = ReadFastIPT('input_file_name') 
%   Returns a structure containing the data in a FAST IPT input file.

if ~exist('input_file','var')
    [fn pn] = uigetfile( ...
        {'*.ipt','Aerodyn input (*.ipt)'; ...
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
ipt.ffn = input_file;


% begin reading input file
readInLinesBlock(fid,17);
NumFoil         =rip(fid,'num');
for k=1:NumFoil
    ipt.FoilNm{k,1} =rip(fid,'qstr');
end
readInLinesBlock(fid,2);
ElmTable           =riptbl(fid,'%f %f %f %f %f %s');
ipt.RNodes    = ElmTable{1};
ipt.AeroTwst  = ElmTable{2};
ipt.DRNodes   = ElmTable{3};
ipt.Chord     = ElmTable{4};
ipt.NFoil     = ElmTable{5};
ipt.PrnElm    = ElmTable{6};
ipt.MultTab   = rip(fid,'str',{'','SINGLE','ReNum','USER'});

fclose(fid);
end

%==========================================================================
%===== FUNCTION DEFINITIONS ===============================================
%==========================================================================
function param = rip(fid,type,varargin)
% read input file parameter
    try
        line = strtrim(fgetl(fid));       % get the next line of text
    catch
        line = '';
%         disp('Warning: found blank line while looking for parameter');
    end
    options = cell(0,1);              % initialize to empty cell
    if nargin > 2
        options=varargin{1};          % deal out the input arguments
    end
    switch type  % handling of input depends on type
        case 'TF'  % type: true/false
            % use sscanf to get the first non-whitespace 
            % group of characters
            param = sscanf(line,'%s',1);
            % examine only the first character to determine true/false
            if upper(param(1))=='T'
                param = 'True';
            elseif upper(param(1))=='F'
                param = 'False';
            else
                error('Unknown option "%s" for input line:\n%s\n',param,line);
            end
        case 'str'   % type: unquoted string
            % use sscanf to get the first non-whitespace
            % group of characters
            param = sscanf(line,'%s',1);
            % try to find a match from the options list
            k=strmatch(upper(param),upper(options));
            if ~isempty(k)
                param=options{k};
            else
                error('Unknown option "%s" for input line:\n%s\n',param,line);
            end
        case 'qstr'  % type: quoted string
            % a quoted string could contain spaces, 
            % which rules out using sscanf\
            % regexp match: beginning of string ^, quote ", 
            %               anything not quote [^"]*, quote "
            s=regexp(line,'^"[^"]*"','match','once');
            if isempty(s)
                param='';          % a quoted string was not found
            else
                param=s;  % trim off any leading whitespace
            end
        case 'num'  % type: single numeric value OR string option (i.e. 'default')
            param = sscanf(line,'%f',1);
            if isempty(param)  
                % numeric value not found; try to read a string parameter
                if isempty(regexp(line,'^\s*"','once'))  % check for quotes
                    % it's an unquoted string
                    param = sscanf(line,'%s',1);
                else
                    % it's a quoted string
                    s=regexp(line,'^"[^"]*"','match','once');
                    param=regexp(s,'[^"]*','match','once'); % remove quotes         
                end
                % try to find a match from the options list
                k=strmatch(upper(param),upper(options));
                if ~isempty(k)
                    param=options{k};
                else
                    error('Unknown option "%s" for input line:\n%s\n',param,line);
                end
            end
        case 'csv'  % type: comma separated value list
            % get the input field
            % regexp match: beginning of string ^, set of zero or more []* 
            %               digits \d whitespace \s or ,.-+
            csv = regexp(line,'^[\d\s,.-+]*','match','once');
            csv = regexp(csv,'[^\s,]+','match');
            param = zeros(1,length(csv));
            for k=1:length(csv)
                param(k) = str2double(csv{k});
            end
    end
end

function table = riptbl(fid,frmt)
    table = textscan(fid,frmt);
end

function readInLinesBlock(fid,numLinesToRead)
    %reads in numLinesToRead, does nothing with them
    for i=1:numLinesToRead
       fgetl(fid); 
    end
end