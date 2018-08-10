clc
clear all;
FilePathAndNameInit
pp = PosPath;

se=strel('disk',2);
for iFrame = g_start_frame:g_frame_interval:g_end_frame
    %tt = cputime;
    
    vp = VideoPath;
    mask=ImageRead(vp,'Seg',iFrame);
    mask=mask>100;
    nrows=size(mask,1);ncols=size(mask,2);
    
    
    peaks=regionprops(mask, 'centroid');
    currPts = cat(1, peaks.Centroid);       %get currPts in CurFrame
%     mask_dilate=imclose(mask,se);
%     peaks_dilate=regionprops(mask_dilate,'area');
%     currArea = cat(1, peaks_dilate.Area);   %get currArea in CurFrame
%     idx_interact =find(currArea>40 & currArea<300);
%     num_interact =0;
%     for i=1:length(idx_interact)
%         idx=idx_interact(i);
%         num_interact=num_interact+round(currArea(idx)/30)-1;    %get num_interact in CurFrame
%     end
    filename = sprintf('%s\\posInfo%06d.mat',pp,iFrame);
    save(filename,'currPts');
end
% for iFrame = g_start_frame:g_frame_interval:g_end_frame    
%     filename = sprintf('%s\\posInfo%06d.mat',PosPath,iFrame);
%     save(filename,'currPts(iFrame,:)');
% end
clear mask
clear mask_dilate