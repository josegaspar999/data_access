function netcam5_data_tst( tstId )
if nargin<1
    tstId= 5; %6; %5; %4; %3; %2;
end

switch tstId
    case 1
        % show dataId '11':'19'
        for dataId= 11:19
            show_dataset( dataId )
        end
        
    case 2
        show_dataset( '2_on' )
        show_dataset( '2_off' )
        
    case 3
        show_dataset( 'roof_pos1_edge1' )
        show_dataset( 'roof_pos1_edge2' )
        show_dataset( 'roof_pos2_edge1' )
        show_dataset( 'roof_pos2_edge2' )
        
    case 4
        show_dataset( 'survcam_chessboard' )
        
    case {5, 6}
        
        id1= 'survcam_laser_off';
        id2= 'survcam_laser_on';
        id3= 'survcam_pantilt_laser_off';
        id4= 'survcam_pantilt_laser_on';
        if tstId==5
            show_4_datasets( id1, id2, id3, id4 )
        else
            show_4_datasets( id1, id2, id3, id4, struct('ssample',5) )
        end
        
        
    otherwise, error('inv tstId');
end

return; % end of main function


function show_dataset( dataId )
d1= netcam5_data( dataId );

N= length( d1.iRange );
for i= 1:N
    figure(201); clf
    %%f1= sprintf( d1.bfname, d1.iRange(i) );
    %f1= filename_complete( d1.bfname, d1.iRange, i );
    %imshow( f1 ); %mytitle_v0( d1.pname, f1 )
    %mytitle( f1 )
    %xlabel( sprintf('%d of %d', i, N) )
    show_image( d1.bfname, d1.iRange, i );
    drawnow
    if aborttst, break; end % put mouse pointer on the windows "start" button
end


function show_4_datasets( id1, id2, id3, id4, options )
if nargin<5
    options= [];
end

d1= netcam5_data( id1 );
d2= netcam5_data( id2 );
d3= netcam5_data( id3 );
d4= netcam5_data( id4 );

tic
N= length( d1.iRange );
for i= 1:N
    figure(201); clf
    subplot(221); show_image( d1.bfname, d1.iRange, i, options );
    subplot(222); show_image( d2.bfname, d2.iRange, i, options );
    subplot(223); show_image( d3.bfname, d3.iRange, i, options );
    subplot(224); show_image( d4.bfname, d4.iRange, i, options );
    drawnow
    if aborttst, break; end % put mouse pointer on the windows "start" button
end
et= toc;
fprintf(1, '** time per iteration = %fsec\n', et/i );


function show_image( bfname, iRange, i, options )
if nargin<4
    options= [];
end

N= length( iRange );
f1= filename_complete( bfname, iRange, i );

if isempty( options )
    imshow( f1 ); % ~101microsec/img
else
    img= imread(f1);
    if isfield(options, 'ssample')
        ss= options.ssample;
        img= img(1:ss:end, 1:ss:end, :);
    end
    image( img ); axis equal; % ~70microsec/img
end

mytitle( f1 )
xlabel( sprintf('%d of %d', i, N) )


function mytitle_v0( pname, fname )
title( strrep( fname, pname, '' ) )


function mytitle( fname )
[~, fn, ext]= fileparts( fname );
fn= strrep(fn, '_', '\_');
title( [fn ext] )
