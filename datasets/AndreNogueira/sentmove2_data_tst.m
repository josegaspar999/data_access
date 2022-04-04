function sentmove2_data_tst( tstId )
if nargin<1
    tstId= 40; %60; %50; %41; %40; %32; %30;
end

switch tstId
    case {30, 31}
        figure(30); clf
        if tstId==30
            ret= sentmove2_data( 'imv1m_cam0' );
        else
            ret= sentmove2_data( 'imv1m_cam1' );
        end
        imax= length(ret.iRange);
        for i= 1:imax
            fname= sprintf(ret.bfname, ret.iRange(i));
            imshow( fname )
            title( sprintf('img %i of %d', i, imax) )
            drawnow
            if aborttst, break; end
        end

    case 32
        figure(30); clf
        ret1= sentmove2_data( 'imv1m_cam0' );
        ret2= sentmove2_data( 'imv1m_cam1' );
        imax= length(ret1.iRange);
        for i= 1:imax
            f1= sprintf(ret1.bfname, ret1.iRange(i));
            f2= sprintf(ret2.bfname, ret2.iRange(i));
            % subplot(121); imshow( f1 )
            % subplot(122); imshow( f2 )
            img3= imread(f1); img3(:,:,2)= img3; img3(:,:,3)= imread(f2);
            imshow(img3)
            title( sprintf('img %i of %d', i, imax) )
            drawnow
            if aborttst, break; end
        end
        
    case 40
        % Set up the figure and dataset
        [~,f1,f2]=set_double_fig;
        ret= sentmove2_data( 'mfpf_02' );
        imax= length(ret.iRange);
        
        % Set up the orientation plot
        tp = theaterPlot('Parent',f2,'XLimit',[-2 2],'YLimit',[-2 2],'ZLimit',[-2 2]);
        op = orientationPlotter(tp,'DisplayName','Robot Orientation',...
            'LocalAxesLength',2);
        view(f2,[-110,38]);
        title(f2, 'Robot Orientation');
        
        % Get the dataset images and IMU data
        Images = readtable( sentmove2_data([], '../img.txt') );
        tImages = table2array(Images(:,1));
        fileImages = table2array(Images(:,2));
        
        IMU = load( sentmove2_data( [], '../imu.mat') );
        t = IMU.time_float(:,1);
        quat = IMU.quat';
        quat0 = quat(1,:);
        imumax = IMU.ii;
        
        for i= 1:imax
            
            imshow( [ret.pname, fileImages{i}], 'Parent',f1)
            title( f1,sprintf('img %i of %d', i, imax) )
            
            idx = find( t > tImages(i), 1 );        
            
            if ~isempty(idx)
                plotOrientation(op,...
                    quaternion(quatmultiply(quatinv(quat0),quat(idx,:))) );
                title( f2,sprintf('imu orientation %i of %d', idx, imumax) )
            end
            
            drawnow
            if aborttst, break; end
        end
        
        
        
        
end

end


function [fall, f1, f2] = set_double_fig
    fall = figure(99);
    oldUnits = get( fall, 'Units' );
    set( fall, 'Units', 'normalized' );
    set( fall, 'Position', [0.01,0.2,0.7,0.4] );
    set( fall, 'Units', oldUnits );

    % models_fig = subplot('position',[0.05 0.1 0.05 0.8]);
    f1 = subplot('position',[0.05 0.1 0.425 0.8]);
    f2 = subplot('position',[0.575 0.1 0.375 0.8]);
    
    view(-180,0);
end
