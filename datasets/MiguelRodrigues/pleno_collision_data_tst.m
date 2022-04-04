function pleno_collision_data_tst( tstId )
%
% This function can run without arguments, just press F5
%
% Usages:
% pleno_collision_data_tst      % show the default demo
% pleno_collision_data_tst(1)   % show dataIdNumStr & dataId for all datasets
% pleno_collision_data_tst(2)   % show struct info for all datasets
% pleno_collision_data_tst(3)   % show path (location) for all datasets
% pleno_collision_data_tst(4)   % show thumbnails whenever datasets have them

if nargin<1
    tstId= 4;
end
options= [];

switch tstId
    case 1, show_datasets_info( struct('displayFlags','i') )
    case 2, show_datasets_info( struct('displayFlags','s') )
    case 3, show_datasets_info( struct('displayFlags','nIp') )
    case 4, show_datasets_info( options )
end


function y= default_option(x, options, fieldname)
y= x;
if isfield(options, fieldname)
    y= options.(fieldname);
end


function show_datasets_info( options )
ret = pleno_collision_data([], struct('all_data_list',1) );
displayFlags= default_option( 'pt', options, 'displayFlags' );
for i= 1:length(ret)
    x= ret{i};
    for j= displayFlags
        switch j
            case 'n', fprintf(1, '\n');
            case 'i', fprintf(1, '%s\t%s\n', x.dataIdNumStr, x.dataId);
            case 'I', fprintf(1, 'idNumStr=''%s''\tid=''%s''\n', ...
                    x.dataIdNumStr, x.dataId);
            case 's', disp(x)
            case 'p', disp(x.pname)
            case 't', show_thumbs( x )
        end
    end
end


function show_thumbs( x )
fnames= xtree( [x.pname '*.png'], struct('ret_list','', 'get_files',''));
if ~isempty(fnames)
    N= length(fnames);
    figure( 1000+str2num(x.dataIdNumStr) ); clf;
    for i=1:N
        subplot(1,N,i)
        imshow( fnames{i} );
        [p,f,e]= fileparts( fnames{i} );
        title( [f e], 'interpreter', 'none' )
    end
end
