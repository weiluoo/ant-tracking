clc
clear all;
FilePathAndNameInit
figure(1);

showindex = 3;%1 for branchinof,2 for big branchinfo,3 for linkedbranchinfo,

switch showindex
    case 1
        load(sprintf('%s\\branchInfo_%s.mat',VideoPath,VideoName),'branchinfo');
    case 2
        load(sprintf('%s\\BigBranchInfo_%s.mat',VideoPath,VideoName),'BigBranchInfo');
        branchinfo = BigBranchInfo;
    case 3        
        load(sprintf('%s\\linkedBranchinfo_%s.mat',VideoPath,VideoName),'linkedBranchinfo');
        branchinfo = linkedBranchinfo;
end

%idxShowAnts = [1,10,20,30,40,50,69,75,79];
idxShowAnts = 1:length(branchinfo);
len = length(idxShowAnts);
pos = zeros(len,2);
%for iFrame = branchinfo(idxShowAnts).frame(1):g_frame_interval:branchinfo(idxShowAnts).frame(2)
%for iFrame = g_start_frame:g_frame_interval:g_end_frame
iFrame = g_start_frame;%g_end_frame - 300;%g_start_frame;
bContinue = true;

for iFrame = g_start_frame:g_frame_interval:g_end_frame

    %imag = ImageRead('Orig',iFrame);
    imag = ImageRead(VideoPath,'Orig',iFrame);
        
    for i = 1:len
        idx = idxShowAnts(i);
        if(iFrame >= branchinfo(idx).frame(1) && iFrame <= branchinfo(idx).frame(2))
            iPos = iFrame - branchinfo(idx).frame(1) + 1;
            pos(i,:) = round(branchinfo(idx).pos(iPos,:));
        else
            pos(i,:) = [20*i,1];
        end
            
    end
    
    
    imshow(imag,[]);
    hold on;    
    for i = 1:len
        if(pos(i,2) > 2) 
            plot(pos(i,1),pos(i,2),'o','Linewidth',1,'Markersize',5,'Color','g');
            text(pos(i,1),pos(i,2)+10,sprintf('%d',idxShowAnts(i)),'Color','r');
        end
    end

    title(int2str(iFrame));
%     text(10,size(imag,1)/2,int2str(iFrame),'Color','g');
%     drawnow;
    hFrame = getframe(gca);
    imwrite(hFrame.cdata,sprintf('C:\\Users\\xuron\\workshop\\merge\\Data\\Visual\\frame%06d.png',iFrame),'png');
%     pause(.5);
    
%     key = [];
%     %key = input('direction?w/s:[w]','s');
%     if isempty(key)
%           key = 'w';
%     end
%     if(key == 'w')
%         if(iFrame < g_end_frame)
%             iFrame = iFrame + 1;
%             if(iFrame > g_end_frame)
%                 iFrame = g_end_frame;
% %                 break;
%             end
%         else
%             bContinue = false;
%         end        
%     end
%     if(key == 's')
%         if(iFrame > 1)
%             iFrame = iFrame -1;
%             if(iFrame < g_start_frame)
%                 iFrame = g_start_frame;
% %                 break;
%             end
%         else
%             bContinue = false;
%         end
%         
%     end
    
end

