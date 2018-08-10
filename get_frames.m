clear all
FilePathAndNameInit
    
%go
vd = VideoReader(VideoPathAndFileName);
iNumOfFrames = vd.NumberOfFrames;

for i = 1:iNumOfFrames
    vf = read(vd,i);
    imwrite(vf,sprintf('%s\\Orig\\frame%06d.jpg',VideoPath,i));

end

clear all