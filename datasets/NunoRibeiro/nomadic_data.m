function ret = nomadic_data(dataId, options)

if nargin < 2
    options = [];
end
if nargin < 1
    dataId = 'seq05';%'seq07'; %'vid07';
end
if isnumeric(dataId)
    dataId= num2str(dataId); % enforce dataId to be a string
end

ret = get_info(dataId, options);

return; % end of main function


% ------------------------------------------------------------------------
function ret = get_info(dataId, options)

% Find the path of base data folder (common to all datasets):
%
p = which('nomadic_data.m'); p = strrep(p,'nomadic_data.m','');
p = strrep(p,'\','/');

% Find the specific dataset given the dataId:
%
mydata= get_mydata;
ind= [];
for n= 1:length(mydata)
    x= mydata{n};
    if strcmp(dataId, x.id)
        ind= n;
        break
    end
end
if isempty(ind)
    error(['dataset not found: ' dataId])
end

% Fill the return information:
%   bfname = path + filename
%   iRange = frame numbers (can be a subset; may have repeated frames e.g.
%     [1:3:1000 999:-3:1])
%
bfname = [p mydata{ind}.bfname];
iRange = mydata{ind}.iRange;
src = mydata{ind}.src;
ret= struct('dataId',dataId, 'src',src, 'bfname',bfname, 'iRange',iRange);

if strcmp(ret.src, 'vidfile')
    % suggest not using old aviread.m (use mmreader.m, Matlab >= 2010a)
    ret.bypass_aviread= [];
end

% just for debug:
% ret.bfname= which('xylophone.mpg'); % standard mpeg file in windows
% ret.iRange= 1:141;

return


% ------------------------------------------------------------------------
function mydata= get_mydata

mydata= {
    struct('id','vid04', 'src','vidfile', 'bfname','130716_videos/seq4.avi', 'iRange',1:844); ...
    struct('id','vid05', 'src','vidfile', 'bfname','130716_videos/seq5.avi', 'iRange',1:2101); ...
    struct('id','vid07', 'src','vidfile', 'bfname','130716_videos/seq7.avi', 'iRange',1:1010); ...
    struct('id','mono_vid07', 'src','vidfile', 'bfname','130716_videos/monoslam_seq7.avi', 'iRange',1:1010); ...
    struct('id','seq04',      'src','imgfile', 'bfname','130716_seq4/rawoutput%04d.jpg', 'iRange',0:843); ...
    struct('id','seq04_ss',   'src','imgfile', 'bfname','130716_seq4/rawoutput%04d.jpg', 'iRange',500:550); ...
    struct('id','seq05',      'src','imgfile', 'bfname','130716_seq5/rawoutput%04d.jpg', 'iRange',0:2100); ...
    struct('id','seq05_ss',   'src','imgfile', 'bfname','130716_seq5/rawoutput%04d.jpg', 'iRange',0:950); ...
    struct('id','seq07',      'src','imgfile', 'bfname','130716_seq7/rawoutput%04d.jpg', 'iRange',0:1009); ...
    struct('id','seq07_ss',   'src','imgfile', 'bfname','130716_seq7/rawoutput%04d.jpg', 'iRange',230:330); ...
    struct('id','seq07_ss2',  'src','imgfile', 'bfname','130716_seq7/rawoutput%04d.jpg', 'iRange',[230:270 270:-1:230]); ...
    };
