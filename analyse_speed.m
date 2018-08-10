clc
clear all;
FilePathAndNameInit


vec_movement=zeros(1,g_nFrames);
vec_activeant=zeros(1,g_nFrames);
vec_fastant=zeros(1,g_nFrames);

load(sprintf('%s\\linkedBranchinfo_%s.mat',VideoPath,VideoName),'linkedBranchinfo');
%     branchinfo_temp=linkedBranchinfo;
%     load(strcat('C:\research\ant videos_12-07-15\seg\',num2str(video_num),'_tracks_interact_2.mat'),'linkedBranchinfo');
%     branchinfo_temp=[branchinfo_temp,linkedBranchinfo];
%     load(strcat('C:\research\ant videos_12-07-15\seg\',num2str(video_num),'_tracks_interact_3.mat'),'linkedBranchinfo');
%     branchinfo_temp=[branchinfo_temp,linkedBranchinfo];
%     load(strcat('C:\research\ant videos_12-07-15\seg\',num2str(video_num),'_tracks_interact_4.mat'),'linkedBranchinfo');
%     branchinfo_temp=[branchinfo_temp,linkedBranchinfo];
%     clear linkedBranchinfo;
%     linkedBranchinfo=branchinfo_temp;

% load(strcat('C:\research\ant videos_09-20-15\',num2str(video_num),'_segment\tracklet.mat'),'linkedBranchinfo');
nTrack=length(linkedBranchinfo);


idx_kick=[];

for ii=1:nTrack
    startframe=linkedBranchinfo(ii).frame(1);
    endframe=linkedBranchinfo(ii).frame(2);
    if endframe-startframe<=60
        idx_kick=[idx_kick;ii];
    end
end
idx_total=1:nTrack;
idx_keep=setdiff(idx_total,idx_kick);
Branchinfo=linkedBranchinfo(idx_keep);

nTrack=length(Branchinfo);
for ii=1:nTrack
    startframe=Branchinfo(ii).frame(1);
    endframe=Branchinfo(ii).frame(2);
    for iii=(g_frame_interval+1):g_frame_interval:endframe-startframe
        loc1=Branchinfo(ii).pos(iii-g_frame_interval,:);
        loc2=Branchinfo(ii).pos(iii,:);
        movement=sqrt((loc1(1)-loc2(1))^2+(loc1(2)-loc2(2))^2);
        vec_movement(startframe+iii-g_frame_interval:startframe+iii-1)=vec_movement(startframe+iii-1)+movement;%xrh add -1
        vec_activeant(startframe+iii-g_frame_interval:startframe+iii-1)=vec_activeant(startframe+iii-1)+1;%xrh add -1
        if movement>=0.5
            vec_fastant(startframe+iii-g_frame_interval:startframe+iii-1)=vec_fastant(startframe+iii-1)+1;
        end
    end
end

%        vec_interaction=[vec_interaction;vec_interact];


vec_speed=vec_movement./(vec_activeant+0.000000000001);
save(sprintf('%s\\speedInfo_%s.mat',VideoPath,VideoName),'vec_speed','vec_movement','vec_activeant','vec_fastant');

showSpeedInfo;
