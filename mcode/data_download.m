function ret_= data_download(dataId, options)
%
% Downloading and installing data
%
% Requires the file "data_download_info.m" in the current directory:
%   function datasets= data_download_info
%   datasets= {...
%     struct('dataId', 'ident1', 'url', 'http://my.site/filename1.zip'), ...
%     struct('dataId', 'ident2', 'url', 'http://my.site/filename2.zip'), ...
%     };
%
% Given the sample data in "data_download_info.m", data_download.m without
% arguments will unzip "filename1.zip" and "filename2.zip" to subfolders in
% the directory holding "data_download_info.m". The subfolders have the
% names "filename1" and "filename2".
%
% It is possible to use an optional file "data_download_infox.m" to define
% on a per-user basis which datasets are of interest. In other words, a
% data server usually lists all the datasets, and locally, each user has
% the possibility to exclude datasets irrelevant to his work.
%   function exclude= data_download_infox
%   exclude= {
%     'ignore_dataId', 'id_string'; ...
%     'ignore_url', 'url_string'; ...
%     '%xpto', 'this line is ignored'; ...
%     '', 'this line is ignored'; ...
%     };

% options:
% 'unattended', 'url', 'ignore', 'dataId', 'ofname'

% 11.4.2011, 29.4.2011 (info as structs), 3.5.2011 (datasets excl), JG
% 15.4.2019 (unattended install), JG

if isempty(which('data_download_urlwrite'))
    error('data_download_urlwrite.m not found in the path');
end

if nargin<2
    options= [];
end
if nargin<1 || isempty(dataId)
    dataId= define_datasets_to_download( options ); % enter the interactive mode
end
ret2= [];

% data download and install
%
if isnumeric(dataId)
    % is a number (TO DO: move this if into the *_exec fn)
    ret2= data_download_exec(sprintf('%02d', dataId), options);
elseif ischar(dataId)
    % is a single string
    ret2= data_download_exec(dataId, options);
else
    % is a cell
    ret2= {};
    for i=1:length(dataId)
        ret2{i}= data_download_exec(dataId{i}, options);
    end
end

if nargout>0
    ret_= ret2;
end
return; % end of main function


% ------------------------------------------------------------
function mkfolder_if_needed( pname )
if ~exist(pname, 'dir')
    mkdir(pname);
end


function ret= installed_dataset(pname, datasetInfo)
% two cases
% (i) datasetInfo has a field "mkfolder" and that folder exists
% (ii) zipname created folder with its name (without .zip)

if isfield(datasetInfo, 'mkfolder')
    dname= [pname datasetInfo.mkfolder];
else
    zipname= datasetInfo.ofname;
    dname= [pname strrep(zipname,'.zip','')];
end

ret= 0;
if exist(dname, 'dir')
    ret= 1;
end


function dataId= define_datasets_to_download( options )

% basic info
%
datasets= get_all_datasets;
p= datasets_outpath;

% prepare question strings
%   - installed : 100_gnd_mv : 110406_ball_gnd_mv.zip
%   * INSTALL ? : 101_calibr : 110407_calibr_chess.zip
%
str= {};
allDataInstalledFlag= 1;
for i=1:length(datasets)
    str{i}= [datasets{i}.dataId ' : ' datasets{i}.ofname];
    % % if exist(strrep([p datasets{i}.ofname],'.zip',''), 'dir')
    %if installed_dataset(p, datasets{i}.ofname)
    if installed_dataset(p, datasets{i})
        str{i}= ['- installed : ' str{i}];
    else
        str{i}= ['* INSTALL ? : ' str{i}];
        allDataInstalledFlag= 0;
    end
end

% allow going out when everything was already installed
%
if allDataInstalledFlag
    if isfield(options, 'unattended' ) && options.unattended
        dataId= {}; return
    end
    qstr= questdlg({'All data installed.', 'Continue to see list of data to ReInstall?'}, ...
        'reinstall', 'Stop', 'Continue', 'Stop');
    if strcmp(qstr, 'Stop')
        dataId= {}; return
    end
end

if isempty(str)
    msgbox('There are no datasets to install/reinstall.')
    dataId= {}; return
end

% chance to select files to install or not
%
if isfield(options, 'unattended' ) && options.unattended
    s= length(str);
    okFlag= 1;
else
    [s, okFlag] = listdlg('PromptString',...
        {'Select the files to install' ,...
        '(press Cancel to avoid installing any file):'},...
        'SelectionMode','multiple',...
        'ListSize', [300 150], ...
        'ListString',str);
end

% prepare the list of relevant filenames (output "dataId" as a list)
%
dataId= {};
if okFlag && ~isempty(s)
    str2= {'Please confirm the install of:'};
    for i=1:length(s)
        dataId{i}= datasets{s(i)}.dataId;
        str2{i+1}= str{s(i)};
    end
    if isfield(options, 'unattended' ) && options.unattended
        button= 'Yes';
    else
        button= questdlg(str2, 'confirm install', 'Yes','No','No');
    end
    if strcmp(button, 'No')
        dataId= {};
        msgbox('Install canceled');
    end
end

return


% ------------------------------------------------------------
function ret2= data_download_exec(dataId, options)
if nargin<1
    options= [];
end
ret2= [];

% get info on the dataId 
%
ret= get_dataset(dataId);
if isempty(ret)
    error('specified dataId not found')
end

% create a tmp subfolder under "p" (i.e. in "data" folder)
%
p= datasets_outpath;
mkfolder_if_needed( fullfile(p, 'tmp') );

% download the file to a tmp folder
%   ofname= [p 'tmp/' ret.ofname];
ofname= fullfile(p, 'tmp', ret.ofname);
if isfield(ret, 'mkfolder')
    % use also mkfolder as a subfolder of tmp
    ofname= fullfile(p, 'tmp', ret.mkfolder, ret.ofname);
end
downloadNeeded= 1;
if exist( ofname, 'file' )
    str= {'Found previously downloaded:', ofname, 'Download again and overwrite?'};
    button= questdlg( str, 'Download once more?', 'Yes', 'No', 'No' );
    if strcmp( button, 'No' )
        downloadNeeded= 0;
    end
end
if isfield(options, 'download_info') && options.download_info
    ret2= struct('url', ret.url, 'ofname',ofname, 'downloadNeeded',downloadNeeded);
    return
end
if downloadNeeded
    str= {'Please wait, downloading:', ret.url, 'To the tmp file:', ofname};
    h= msgbox(str);
    %urlwrite(ret.url, ofname)
    okFlag= data_download_urlwrite12(ret.url, ofname);
    %     try
    %         data_download_urlwrite12(ret.url, ofname);
    %     catch
    %         if ishandle(h), close(h); end
    %         disp(['FAILED download of: ', ofname]);
    %         errordlg({'FAILED download of:', ofname});
    %         return
    %     end
    if ishandle(h), close(h); end % close the msgbox if the user didn't
    if ~okFlag
        disp(['FAILED download of: ', ofname]);
        errordlg({'FAILED download of:', ofname});
        return
    end
end

% extract the downloaded file
%
if ~exist(ofname, 'file')
    msgbox({'FAILED download of:', ofname});
    return
end

[~,dname,ext]= fileparts( ofname );
% ^ assumed a well formed zip brings inside the foldername
if isfield(ret, 'mkfolder')
    % mkfolder will contain the unzip (instead of the zip filename)
    dname= fullfile( ret.mkfolder );
end

extractNeeded= 1;
if exist( dname, 'dir' )
    str= {'Found extracted:', ofname, 'Extract once more?'};
    button= questdlg( str, 'Extract once more?', 'Yes', 'No', 'No' );
    if strcmp( button, 'No' )
        extractNeeded= 0;
    end
end
if extractNeeded
    if isfield(ret, 'mkfolder')
        p= fullfile(p, ret.mkfolder);
    end
    str= {'Please wait, extracting:', ofname};
    h= msgbox(str);
    try
        if ~strcmpi( ext, '.tgz' )
            unzip( ofname, p )
        else
            untar( ofname, p )
        end
    catch
        warning('Failed extraction of %s', ofname);
    end
    if ishandle(h), close(h); end
end

return


function okFlag= data_download_urlwrite12(url, ofname)
% if ofname ends as .zip and url does not contain ||
% then use the novel fn data_download_urlwrite2()

okFlag= 1;
if ~isempty( strfind(upper(ofname), '.ZIP') ) && ...
        strcmpi( ofname(end-3:end), '.ZIP' ) && ...
        isempty( strfind(url, '|') )
    % use a novel version to handle Dropbox & a ZIP file
    try
        data_download_urlwrite2(url, ofname);
    catch
        okFlag= 0;
    end
else
    % use the older versions for cases of password
    try
        data_download_urlwrite(url, ofname);
    catch
        okFlag= 0;
    end
end

return; % end of function


function fname= url2zipfname(url)

% use last / to find the filename
ind= strfind(strrep(url,'\','/'), '/');
fname= url(ind(end)+1:end);

% remove ||* in the end of the filename
ind= strfind(fname, ' ||'); if ~isempty(ind), fname= fname(1:ind(1)-1); end
ind= strfind(fname, '|'); if ~isempty(ind), fname= fname(1:ind(1)-1); end


function p= datasets_outpath
p= which('data_download_info.m');
p= strrep(p, 'data_download_info.m', '');


function datasets= get_all_datasets

% -- data loading: read from the external fn "data_download_info.m" the
% list of files to download
%
datasets= data_download_info;

% datasets must be a list
if ~iscell(datasets)
    url2zipfname('data_download_info.m is NOT returning a list')
end

% -- verify datasets and exclude the ones having the field 'ignore'
tmp= {};
for i=1:length(datasets)
    % all list elements must be a struct
    if ~isstruct(datasets{i})
        error(['datasets element ' num2str(i) ' is NOT a struct'])
    end
    % required field "url"
    if ~isfield(datasets{i}, 'url')
        error(['datasets element ' num2str(i) ' has NO url field']);
    end
    % keep only datasets NOT labeled with 'ignore'
    if ~isfield(datasets{i}, 'ignore')
        tmp{end+1}= datasets{i};
    end
end
datasets= tmp;

% -- complete missing data
%
for i=1:length(datasets)
    % get struct from the list
    ds= datasets{i};
    
    % required field "dataId"
    if ~isfield(ds, 'dataId')
        ds.dataId= sprintf('%02d', i);
    end
    
    % complete the field "ofname" if not given
    if ~isfield(ds, 'ofname')
        ds.ofname= url2zipfname(ds.url);
    end
    
    % put struct back to the list
    datasets{i}= ds;
end

% -- process exclusion of datasets if specified in 'data_download_infox.m'
%
if exist('data_download_infox.m', 'file')
    datasets= datasets_exclude(datasets);
end

return


function datasets2= datasets_exclude(datasets)
datasets2= {};
ret= data_download_infox;

for i=1:length(datasets)
    
    % try to find a reason to exclude datasets{i}
    %
    dataseti= datasets{i};
    excludeFlag= 0;
    for j=1:size(ret,1)
        cmd= ret{j,1};
        if isempty(cmd) || cmd(1)=='%'
            continue;
        end
        switch cmd
            case 'ignore_url'
                if strcmp(ret{j,2}, dataseti.url)
                    excludeFlag=1; break;
                end
            case 'ignore_dataId'
                if strcmp(ret{j,2}, dataseti.dataId)
                    excludeFlag=1; break;
                end
            otherwise
                error(['Invalid command in data_download_infox.m : ' cmd])
        end
    end
    
    % if there is no reason to exclude datasets{i} then keep it
    %
    if ~excludeFlag
        datasets2{end+1}= datasets{i};
    end
    
end

return


function ret= get_dataset(dataId)
% get one specific dataset
datasets= get_all_datasets;
for i=1:length(datasets)
    if strcmp(dataId, datasets{i}.dataId)
        ret= datasets{i};
        return
    end
end
ret= [];
