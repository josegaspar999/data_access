function datasets= data_download_info
datasets= {...
    struct('dataId','chess_cube',         'ofname',	'210721_calibr_chess_cube.zip', 'url', 'https://www.dropbox.com/s/4f0jexfpfo56obq/210721_calibr_chess_cube.zip?dl=1'), ...
    struct('dataId','chess_cube_blender', 'ofname',	'210929_chess_cube_blender.zip', 'url', 'https://www.dropbox.com/s/vljnvfhaakh7524/210929_chess_cube_blender.zip?dl=1'), ...
    struct('dataId','FaceMiguel_Z60_F60', 'ofname',	'FaceMiguel_Z60_F60.zip', 'url', 'https://www.dropbox.com/s/u8z6jr48xgjsvye/FaceMiguel_Z60_F60.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/fk5xb1y7n4koixq/210720_collision_with_background.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/pb3ukioy0wz0s4u/210720_forward_camera_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/jl2yhb66kp0e0bg/210720_large_colision_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/5gkabwgwqgsg5bq/210720_large_non_colision_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/ixz2n2xymiwzs2d/210720_lateral_camera_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/2vxy9kvfsjkmrcx/210720_non_lambertian_surfaces.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/mxz155ce4il0o3n/210720_small_collision_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/ke0jnzt2bqmoxb2/210720_small_non_collision_movement.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/bouoy9ekfm21p5d/211019_Camera_Backwards_no_collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/8kgzh8xzur29i1f/211019_Camera_Forward_collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/vcky8mk7ag54ax5/211019_Car_no_collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/w9kqmcivkt8hvfz/211019_Cards_collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/19dlypar9h0gvl1/211019_Cards_no_collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/jpxlqvfg89xx9my/211019_Camera_Movement_with_Collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/l778zdr5zvd7cag/211019_Camera_Movement_without_Collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/kj6ajayaa5a55l5/211019_Object_Movement_with_Collision.zip?dl=1'), ...
    myurl('https://www.dropbox.com/s/kmt71rlk89dsjge/211019_Object_Movement_without_Collision.zip?dl=1'), ...
    };
return


function ret= myurl(url)
% from url make : dataId, ofname
% ofname: is "url" from "last /" till "?"
i1= find(url == '/'); i1= i1(end);
i2= find(url == '?'); i2= i2(1);
ofname= url( i1+1:i2-1 );
dataId= strrep(ofname, '.zip', '');
ret= struct('dataId',dataId, 'ofname',ofname, 'url',url);
return