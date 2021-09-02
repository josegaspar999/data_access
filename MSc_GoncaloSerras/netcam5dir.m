function p= netcam5dir
p= 'c:\msc\netcam5\';
if ~exist(p, 'dir')
    p= [fileparts(which('netcam5dir')) '\..\'];
end
