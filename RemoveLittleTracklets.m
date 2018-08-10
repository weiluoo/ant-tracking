clc
clear all;
FilePathAndNameInit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%formulate another LAP to link the broken branches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(sprintf('%s\\branchInfo_%s.mat',VideoPath,VideoName),'branchinfo');
usedID = length(branchinfo);
usedIDNew = 1;
for Id = 1:usedID    
    len = branchinfo(Id).frame(2)-branchinfo(Id).frame(1)+1;
    branchinfo(Id).pos = branchinfo(Id).pos(1:len,:);

    mileage(Id) = GetMileAgeOfTracklet(branchinfo(Id).pos);    
    if((mileage(Id) > g_distThre_MileAge))
        BigBranchInfo(usedIDNew) = branchinfo(Id);
        usedIDNew = usedIDNew + 1;
    end
        
end
disp(sprintf('bef remove:%d,aft remove:%d,removed:%d',usedID,usedIDNew,usedID - usedIDNew));
save(sprintf('%s\\BigBranchInfo_%s.mat',VideoPath,VideoName),'BigBranchInfo');