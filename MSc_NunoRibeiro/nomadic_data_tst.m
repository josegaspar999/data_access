function nomadic_data_tst( tstId )
if nargin<1
    tstId=1;
end
if length(tstId)>1
    % multiple tests run: nomadic_data_tst( 1:3 )
    for i= tstId, nomadic_data_tst(i); end
    return
end

switch tstId
    case 1, x= nomadic_data;
    case 2, x= nomadic_data('vid04');
    case 3, x= nomadic_data('seq05');
    otherwise, error('inv tstId');
end

% % other usages of image acquisition
% opt= struct('src',x.src, 'bfname',x.bfname, 'bypass_aviread',[]);
% local_iacq_ini(opt);

figure(201);
nimgs= local_iacq_ini(x);
for i= 1:nimgs %length(x.iRange)
    local_iacquire;
    img= local_igetrgn;
    
    figure(201); clf
    imshow(img)
    title(sprintf('img %d of %d', i, length(x.iRange)));
    drawnow;
    if aborttst, break; end
end
local_iacq_end


function abortFlag= aborttst
abortFlag= 0;
mousePt= get(0,'PointerLocation');
if max(mousePt)<100,
    fprintf(1,'\n*** aborted: mouse pointer in [0, 100, 0, 100] ***\n\n');
    abortFlag= 1;
end
