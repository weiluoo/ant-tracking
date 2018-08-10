clc
clear all
FilePathAndNameInit
    
workingDir = 'C:\Users\xuron\workshop\merge\Data\';
%go
% create the video writer with 1 fps
 writerObj = VideoWriter('C:\Users\xuron\workshop\merge\Data\VisualVideo','Uncompressed AVI');
 writerObj.FrameRate = 5;
%  writerObj.Quality = 100;
%  [image,map] = imread(sprintf('C:\\Users\\xuron\\workshop\\merge\\Data\\Visual\\frame%06d.tif',1));
%  writerObj.Colormap = map;
 % set the seconds per image
%  secsPerImage = [5 10 15];
 % open the video writer
 open(writerObj);
 % write the frames to the video
%for iFrame = 1:1:12%g_start_frame:g_frame_interval:g_end_frame
imageNames = dir(fullfile(workingDir,'Visual','*.png'));
imageNames = {imageNames.name}';
for ii = 1:length(imageNames)
   image = imread(fullfile(workingDir,'Visual',imageNames{ii}));
     % convert the image to a frame
%      image = imread(sprintf('C:\\Users\\xuron\\workshop\\merge\\Data\\Visual\\frame%06d.bmp',iFrame));
%      frame = im2frame(image);
     
     
     writeVideo(writerObj, image);
 end
 % close the writer object
 close(writerObj);
 
 