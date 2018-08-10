function showCurrentlyExistedAntsInBranch(branchinfo,iFrame)
subplot(2,1,1);
global VideoPath;
global VideoName;
%1 for branchinof,
%2 for big branchinfo,
%3 for linkedbranchinfo,
% showindex = 1;
% 
% switch showindex
%     case 1
%         load(sprintf('%s\\branchInfo_%s.mat',VideoPath,VideoName),'branchinfo');
%     case 2
%         load(sprintf('%s\\BigBranchInfo_%s.mat',VideoPath,VideoName),'BigBranchInfo');
%         branchinfo = BigBranchInfo;
%     case 3
%         load(sprintf('%s\\linkedBranchinfo_%s.mat',VideoPath,VideoName),'linkedBranchinfo');
%         branchinfo = linkedBranchinfo;
% end

%idxShowAnts = [3,72];
idxShowAnts = 1:length(branchinfo);
len = length(idxShowAnts);
pos = zeros(len,2);
imag = ImageRead(VideoPath,'Seg',iFrame);



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

text(10,size(imag,1)/2,int2str(iFrame),'Color','g');
drawnow;

end

