clc
clear all;
FilePathAndNameInit
global g_frame_interval;

iFrame = 1;

bContinue = true;
while(bContinue)

    load(sprintf('%s\\posInfo%06d.mat',PosPath,iFrame),'currPts');
    showAntsOfCurFrame(iFrame,currPts);
    
    
    bContinue = false;
    pause(.5);
    %key = [];
    key = input('direction?w/s:[w]','s');
    if isempty(key)
          key = 'w';
    end
    if(key == 'w')
        if(iFrame < g_end_frame)
            iFrame = iFrame + 1;
        end
        bContinue = true;
    end
    if(key == 's')
        if(iFrame > 1)
            iFrame = iFrame -1;
        end
        bContinue = true;
    end
    
end