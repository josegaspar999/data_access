function ini_path

if ~exist('data_download.m', 'file')
    p= fileparts( which('ini_path.m') );
    if isempty(p)
        error('please run "ini_path.m" in folder where it is stored')
    end
    p= [p filesep '..' filesep 'mcode'];
    path( path, p );
end
