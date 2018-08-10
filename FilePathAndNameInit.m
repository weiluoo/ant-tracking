%FilePathAndName Init
global  VideoPath;
global g_frame_interval;
global PosPath;
global VideoName;
opt_bUseAbsolutePath = false;
VideoName = '4-15-2016-150ant-B_20';
VideoPath = '.\Data';
if(opt_bUseAbsolutePath)
    VideoPath = 'C:\Users\xuron\workshop\merge\Data';    
end
VideoPathAndFileName = [VideoPath,'\',VideoName,'.mp4'];
OrigPath = strcat(VideoPath,'\Orig');
SegPath = strcat(VideoPath,'\Seg');
PosPath = strcat(VideoPath,'\Pos');

g_start_frame=0001;
g_frame_interval=1;
g_end_frame=10800;
g_nFrames = g_end_frame-g_start_frame;

g_distThre_S = 10^2; %The largest movement between two frames, for gating region
g_distThre_T = 60; %the largest gap between broken trajectories.
g_distThre_MileAge = 10;