function ret = pleno_collision_data(dataId, options)
% Function that returns the dataset informations
%
% Arguments:
%           dataId - Identifier of the dataset (same as the folder name of
%                    the dataset);
%           options - options - This struct contains information like:
%                     dataset dir, image_name, etc;
% Return:
%           Returns a struct with the dataset ID, name, path, pan/ tilt
%           information, zoom, etc.

if nargin < 2, options = []; end
if nargin < 1, dataId = 1; end
if isnumeric(dataId), dataId = num2str(dataId); end

ret = mydata_select_one(dataId, options);

return; % end of main function


% ----------------------------------------------------------------------
function ret = mydata_select_one(dataId, options)

% get path into "p"
cfname= dbstack(1); cfname= cfname.file;
p= which(cfname); p= strrep(p,cfname,''); p= strrep(p,'\','/');

% links for all data
mydata = mydata_all(p);
if isfield(options, 'all_data_list') && options.all_data_list
    % usage: ret = pleno_collision_data([], struct('all_data_list',1) )
    ret= mydata;
    return
end

% find dataset name or dataset folder
for n = 1:size(mydata,1)
    ret= mydata{n};
    if strcmp(dataId, ret.dataIdNumStr) || strcmp(dataId, ret.dataId)
        return
    end
end
error(['dataset not found: ' dataId])


function mydata = mydata_all(p)
mydata1 = mydata_calib(p);
mydata2 = mydata_face(p);
mydata3 = mydata_speed(p);
mydata= cat(1, mydata1, mydata2, mydata3);
return


% ----------------------------------------------------------------------
function mydata = mydata_calib(p)
calibData= {
    '1', '210721_calibr_chess_cube', 'Test_Cube.mat', '2Dpoints.mat'; ...
    '2', '210929_chess_cube_blender', 'Test_Cube.mat', '2Dpoints.mat'; ...
    };

mydata= {};
for ind = 1:size(calibData,1)
    dataId0= calibData{ind,1};
    dataId1= calibData{ind,2};
    
    pname    = [p calibData{ind,2} '/'];
    lfname   = [pname calibData{ind,3}];
    ptsfname = [pname calibData{ind,4}];
    
    ret= struct('dataIdNumStr', dataId0, 'dataId',dataId1, ...
        'pname',pname, 'lfname',lfname, 'ptsfname',ptsfname );
    mydata{end+1,1}= ret;
end


% ----------------------------------------------------------------------
function mydata = mydata_face(p)
mydata= data_download_info_getx( p, 3, 100, 'IMG*.mat' );


function mydata = mydata_speed(p)
mydata= data_download_info_getx( p, 4:20, 200, 'LF*.mat' );


function mydata= data_download_info_getx( p, dataIdRange, baseNum, patt )
% use info in data_download_info.m to get datasets info
datasets= data_download_info;
datasets= datasets(dataIdRange);

% arrange data in a easy to use format
mydata= {};
for ind= 1:length(datasets)
    x= datasets{ind};

    dataId0 = num2str( baseNum+ind );
    dataId1 = x.dataId;
    pname   = [p x.dataId '/'];
    
    ret= struct('dataIdNumStr', dataId0, 'dataId',dataId1, ...
        'pname',pname );
    ret= add_lfnames( ret, pname, patt );

    mydata{end+1,1}= ret;
end


function ret= add_lfnames( ret, pname, patt )
% pathname "pname" together with filenames pattern "patt" gives the files
fnames= xtree([pname patt], struct('ret_list','', 'get_files',''));
fnames= sort(fnames);

% ret.lfname - is always defined, even if it is empty
ret.lfname= '';
if ~isempty(fnames)
    ret.lfname= fnames{1};
end

% one may obtain lfname* fieldnames (check ret.lfnameNum to see how many)
% in case isempty(fnames), ret.lfname1 will not exist
ret.lfnameNum= length(fnames);
for i=1:length(fnames)
    fieldname= sprintf('lfname%d', i);
    ret.(fieldname)= fnames{i};
end
return
