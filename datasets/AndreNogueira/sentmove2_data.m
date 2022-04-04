function ret = sentmove2_data(dataId, options)
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

% usages:
% ret= sentmove2_data( dataId )
% fullfilename= sentmove2_data( dataId, filename )

% to test this file: 
% sentmove2_data_tst

if nargin < 1
    dataId = 1;
end
if isnumeric(dataId)
    dataId = num2str(dataId);
end

persistent NC3_dataId
if isempty(dataId)
    dataId= NC3_dataId;
else
    NC3_dataId= dataId;
end

if nargin < 2
    options = [];
end
if ischar(options)
    % convert filename to a struct
    options= struct('getFullFilename', options);
end

ret = get_info(dataId, options);

return; % end of main function


function ret = get_info(dataId, options)

% get path into "p"
cfname= dbstack(1); cfname= cfname.file;
p= which(cfname); p= strrep(p,cfname,''); p= strrep(p,'\','/');

mydata = get_mydata(p);
ind = [];
for n = 1:size(mydata,1)
    % find dataset name or dataset folder
    if strcmp(dataId, mydata{n,1}) || strcmp(dataId, mydata{n,2})
        ind = n;
        break
    end
end
if isempty(ind)
    error(['dataset not found: ' dataId])
end

pname  = [p mydata{ind,2} '/'];
bfname = [pname mydata{ind,3}];
iRange =  mydata{ind,4};

% return general information
ret= struct('dataId',dataId, 'pname',pname, ...
    'bfname',bfname, 'iRange',iRange, 'NbStepsMax', mydata{ind,5} );

% if asked, return just a fullfilename
if isfield(options, 'retJustPath') && options.retJustPath
    ret= ret.pname;
elseif isfield(options, 'getFullFilename')
    ret= [ret.pname options.getFullFilename];
end

% expand encoded iRange
if isfield(ret, 'iRange') && ischar(ret.iRange)
    ret.iRange= eval(ret.iRange);
end

return


function mydata = get_mydata(p)

% use filename_complete.m to complete ims1_cam0 iRange
% this requires matlab.my updated >= 22.10.2020


ind2imv1e_cam0 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';
ind2imv1e_cam1 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';

ind2imv1m_cam0 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';
ind2imv1m_cam1 = 'repmat(523912143104,1,1711) +(0:1710).*49999872 +floor((0:1710)/2).*256';

ind2imv1d_cam0 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';
ind2imv1d_cam1 = 'repmat(523912143104,1,1711) +(0:1710).*49999872 +floor((0:1710)/2).*256';

ind2imv2e_cam0 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';
ind2imv2e_cam1 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';

ind2imv2m_cam0 = 'repmat(3886005760512,1,2348) +(0:2347).*49999872 +floor((0:2347)/2).*256';
ind2imv2m_cam1 = 'repmat(3886005760512,1,2348) +(0:2347).*49999872 +floor((0:2347)/2).*256';

ind2imv2d_cam0 = 'repmat(523912143104,1,1710) +(0:1709).*49999872 +floor((0:1709)/2).*256';
ind2imv2d_cam1 = 'repmat(523912143104,1,1711) +(0:1710).*49999872 +floor((0:1710)/2).*256';

mf_01 = '1:42';
mf_02 = '1:70';
mf_03 = '1:77';
mf_04 = '1:103';
mfcf_01 = '1:65';
mfcf_02 = '1:70';
mc_01 = '1:145';
mc_02 = '1:136';
mfpf_01 = '1:125';
mfpf_02 = '1:166';

NbMax_EuRoC = 1000;
NbMax_mf_01 = 74;
NbMax_mf_02 = 135;
NbMax_mf_03 = 186;
NbMax_mf_04 = 254;
NbMax_mfcf_01 = 115;
NbMax_mfcf_02 = 126;
NbMax_mc_01 = 262;
NbMax_mc_02 = 234;
NbMax_mfpf_01 = 223;
NbMax_mfpf_02 = 309;

sequences = '0:2169';

mydata= {
    'imv1m_cam0', 'im_V1_02_medium/mav0/cam0/data', '1403715%d.png', ind2imv1m_cam0, NbMax_EuRoC; ...
    'imv1m_cam1', 'im_V1_02_medium/mav0/cam1/data', '1403715%d.png', ind2imv1m_cam1,NbMax_EuRoC; ...
    %'imv2m_cam0', 'im_V2_02_medium/mav0/cam0/data', '141339%d.png', ind2imv2m_cam0,NbMax_EuRoC; ...
    'mf_01', 'mf_01/img', '%d.png', mf_01,NbMax_mf_01; ...
    'mf_02', 'mf_02/img', '%d.png', mf_02,NbMax_mf_02; ...
    'mf_03', 'mf_03_640/img', '%d.png', mf_03,NbMax_mf_03; ...
    'mf_04', 'mf_04/img', '%d.png', mf_04,NbMax_mf_04; ...
    'mfcf_01', 'mfcf_01/img', '%d.png', mfcf_01,NbMax_mfcf_01; ...
    'mfcf_02', 'mfcf_02/img', '%d.png', mfcf_02,NbMax_mfcf_02; ...
    'mc_01', 'mc_01/img', '%d.png', mc_01,NbMax_mc_01; ...
    'mc_02', 'mc_02/img', '%d.png', mc_02,NbMax_mc_02; ...
    'mfpf_01', 'mfpf_01/img', '%d.png', mfpf_01,NbMax_mfpf_01; ...
    'mfpf_02', 'mfpf_02/img', '%d.png', mfpf_02,NbMax_mfpf_02; ...
    'sequences', 'sequences/ic', 'rawoutput%04d.pgm', sequences,-1; ...
    %'5hours', '5hours_imu', '', '1',1; ...
    };
return
