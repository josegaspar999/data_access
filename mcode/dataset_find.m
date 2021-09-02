function ret= dataset_find( dataId, options )
%
% This function looks to the path of the caller function in order to start
% the search for a dataset. Consequently, please define YOUR own data access
% function, e.g. "mywork_data.m", to stay on the root of a tree of data and
% therefore guide the search for the data.
% 
% Two main struct fields are returned: bfname, iRange. These two fields are
% enough to read in all data files, from any other folder, as bfname
% contains the absolute path.
%
% Required:
% this function, "dataset_find.m" must be called by a local function
%
% Input:
% requires a local function "dataset_info.m"
%
% Output:
% ret: struct : fields dataId, bpname, bfname, iRange; bfname contains bpname.

% Notes:
% the user must create "mywork_data.m" and "dataset_info.m"
% the user may have local caches (not versioned) as they have personal info
% library provides "dataset_find.m"
% library considers possible "dataset_find_local.m" for multiple projects

% Future:
% Create GUI for "dataset_find( [], 'ini' )"
% ask user to go into the GIT/SVN data folder
% use the GIT/SVN folder to propose a "mywork_data.m" name
% files to create: mywork_data.m, dataset_info.m, data_download_info.m

% 12.9.2016, 1.1.2017 (added dataset_info_local.m) JG

if nargin<1
    % get one default dataId (requires a local "dataset_info.m")
    dataId= dataset_find_default;
end

if nargin<2, options= []; end

% enforce dataId to be a string
if ~ischar(dataId)
    if isnumeric(dataId)
        dataId= num2str(dataId);
    else
        error(['dataId must be numeric or a string']);
    end
end

% -- mode 0, 1, 2, 3 or 4:
%
% mode 0:
% check within "dataset_info.m" where dataId has all needed information
% in other words, if all is found in "dataset_info.m" then just return it
%
% mode 1 or 2:
% if not enough information found, then check if it was previously cached
% mode in detail, check relative path (mode 1), check cached info (mode 2)
%
% mode 3 or 4:
% check cached info (mode 3) or ask user (mode 4)

% get (mandatory) starting data from "dataset_info.m"
path0 = get_starting_search_path( options );
dList = dataset_info_load( path0 );

% mode 0, 1 or 2
ret   = dataset_data_complete( path0, dList, dataId, options );

if isempty(ret)
    % mode 3 = check cached info (later try a full search or, mode 4, ask user)
    [foundFlag, path1]= get_saved_path0_alternatives( path0, dList, dataId, options );
    if foundFlag
        ret= dataset_data_complete( path1, dList, dataId, options );
    end
end

if isempty(ret)
    % mode 4 = ask user
    path2= ask_user_path0( dataId );
    if length(path2)>0 && slash2(path2(end))~='/'
        path2= [path2 '/']; % enforce end with '/'
    end
    ret  = dataset_data_complete( path2, dList, dataId, options );
    if ~isempty(ret)
        append_data(dataId, path0, path2);
    end
end

return; % end of main function


% ----------------------------------------------------------------
function p= get_path_to_fn( fname )
% e.g. fname= 'neurocams_data.m'
p = which( fname );
p = strrep(p, fname, '');
p = strrep(p, '\', '/');


% ----------------------------------------------------------------
function startingSearchPath= get_starting_search_path( options )
% get pathname to start the search
% opt1: use name of caller function
% opt2: use given function name
%
if isfield(options, 'startingSearchPath')
    % direct indication of the start searching folder name
    startingSearchPath= options.startingSearchPath;

elseif isfield(options, 'mfileLocateBasePath')
    % indication of path by the location of a mfilename
    startingSearchPath= get_path_to_fn( options.mfileLocateBasePath );

% elseif exist('dataset_info.m', 'file')
%     startingSearchPath= get_path_to_fn( 'dataset_info.m' );
% % ^^ DO NOT use this form as you may have multiple "dataset_info.m" files

else
    % indication of path by the caller 
    startingSearchPath= dbstack;
    if length(startingSearchPath)<3
        error('** Please do not call "dataset_find.m" from the workspace **');
    end
    startingSearchPath= startingSearchPath(3).file; % 3 because sub-fn of main fn
    startingSearchPath= get_path_to_fn( startingSearchPath );
end


function dList = dataset_info_load( path0 )
cd0= cd;
cd(path0);
dList = dataset_info;
cd(cd0);


% ----------------------------------------------------------------
function [foundFlag, path1]= get_saved_path0_alternatives( path0, dList, dataId, options )
% default failure return:
foundFlag= 0; path1= '';

% try to do better than a failure return:
cd0= cd;
cd( path0 );
if exist('dataset_info_local.m', 'file')
    tmp = dataset_info_local;
    % tmp is list Nx2 where column1 contains dataId, and col2 is path0
    for i=1:size(tmp,1)
        if strcmp( tmp{i,1}, dataId )
            foundFlag= 1;
            path1= tmp{i, 2};
            break;
        end
    end
end
cd( cd0 );


% ----------------------------------------------------------------
function ret= dataset_data_complete( path0, dList, dataId, options )
% ret= dataset_path_check( path0, dList, dataId, options );
% 
% function ret= dataset_path_check( path0, dList, dataId, options )

% find dataId in dList
%
foundInd= 0;
for i= 1:length(dList)
    x= dList{i};
    x= x.dataId;
    if isnumeric(x), x= num2str(x); end % convert number to string
    if strcmp(dataId, x)
        foundInd= i;
        break;
    end
end
if foundInd == 0
    error( ['invalid dataId string: ' dataId ])
end

% verify whether [path0 bdname bfname] & iRange work
% use two mandatory-to-exist fields: bfname iRange
%
x= dList{foundInd};
if isfield(x, 'iRange') && ~isempty(x.iRange) && ...
        isfield(x, 'bfname') && ~isempty(x.bfname)
    % just verify whether the information is enough
    x.bpname= [path0 x.bpname];
    if ~exist(sprintf(x.bpname, x.iRange(1)), 'file')
        %error(['failed the exist test given a filename'])
        ret= []; % path0 is wrong, allow top level try another one
        return
    else
        ret= x; % success just found all information ;-)
    end
else
    % if missing bfname then go for sampleFName
    % check whether sampleFName exists and can be used
    if ~isfield(x, 'sampleFName')
        error(['bfname and/or iRange fields are empty, sampleFName must be specified'])
    else
        % try to create bfname iRange from sampleFName
        d= dir([path0 x.bpname x.sampleFName]);
        if isempty(d)
            %error('[sampleFName did not work to find one file]')
            ret= []; % path0 is wrong, allow top level try another one
            return
        end
        [x.bfname, x.iRange]= find_filenames([path0 x.bpname], d(1).name);
        x.bpname= [path0 x.bpname];
        ret= x; % hopefully a success ;-)
    end
end

% provide field "fname" in case of a single file
if isempty(ret.iRange)
    ret.fname= ret.bfname;
end

% travel from the pathname p till "dataId" is totally found
%  (use aux files "dataset_find_info.m", "dataset_find_cache.m")
%  (start from p to obtain p2)
%
% p2= path0;

% use a sample filename to make bfname and iRange
% opt1: use the first filename found with a not-null extension
% opt2: use a given filename
%


% ----------------------------------------------------------------
function dname= ask_user_path0( dataId )
% did not find extra info to load, ask it to the user
%
dname= '';
button= questdlg(['Root of dataset "' dataId '" not found. Specify its path?']);
if strcmp(button, 'Yes')
    dname= uigetdir;
    %if ischar(dname)
    %    append_data(dataId, dname);
    %end
end


function append_data(subdirStr, path0, fullPathStr)
cd0= cd;
cd( path0 );
ofname= 'dataset_info_local.m';

if length(fullPathStr)>0 && slash2(fullPathStr(end))~='/'
    fullPathStr= [fullPathStr '/']; % enforce end with '/'
end

if ~exist(['./' ofname], 'file')
    % if not exist ofname, then make a minimal ofname
    fid= fopen(ofname, 'wt');
    initFlag= 1;
else
    % ofname exists, just append data to it
    fid= fopen(['./' ofname], 'at');
    initFlag= 0;
end

if fid<1
    warning(['failed fopen for "' ofname '"'])
    cd( cd0 );
    return
end

if initFlag
    fprintf(fid, 'function table= %s\n', ofname(1:end-2));
    fprintf(fid, 'table{1,1}=''%s''; ', slash2(subdirStr));
    fprintf(fid, 'table{1,2}=''%s'';\n', slash2(fullPathStr));
    fclose(fid);
else
    fprintf(fid, 'table{end+1,1}=''%s''; ', slash2(subdirStr));
    fprintf(fid, 'table{end,2}=''%s'';\n', slash2(fullPathStr));
    fclose(fid);
end

cd( cd0 );


function y= slash2(x)
y= strrep(x,'\','/');


% ----------------------------------------------------------------
function dataId= dataset_find_default

if ~exist('dataset_info.m', 'file')
    error('File "dataset_info.m" not found. Change to a folder containing that file.')
    % in the future, use uigetfile()
    % consider also a personal cache e.g. dataset_find_local.m
end
ret= dataset_info;
ret= ret{1,1};
dataId= ret.dataId;
%ret= dataset_find( dataId );
