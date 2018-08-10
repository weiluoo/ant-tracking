clc
clear all;
FilePathAndNameInit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%formulate another LAP to link the broken branches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(sprintf('%s\\BigBranchInfo_%s.mat',VideoPath,VideoName),'BigBranchInfo');
usedID = length(BigBranchInfo);
sPos = zeros(usedID,2); ePos = zeros(usedID,2);
for Id = 1:usedID
    len = BigBranchInfo(Id).frame(2)-BigBranchInfo(Id).frame(1)+1;
    BigBranchInfo(Id).pos = BigBranchInfo(Id).pos(1:len,:);
    sPos(Id,:) = BigBranchInfo(Id).pos(1,:);
    ePos(Id,:) = BigBranchInfo(Id).pos(len,:);
end
tmp = cat(1,BigBranchInfo.frame);
sFrames = tmp(:,1); eFrames = tmp(:,2);

dist_S = (repmat(ePos(:,1), [1 usedID])-repmat(sPos(:,1)', [usedID 1])).^2+...
    (repmat(ePos(:,2), [1 usedID])-repmat(sPos(:,2)', [usedID 1])).^2;
dist_T = repmat(eFrames, [1 usedID])-repmat(sFrames', [usedID 1]);
gate_link = dist_S<=g_distThre_S & dist_T>-g_distThre_T & dist_T<0;
gate_link = gate_link - diag(diag(gate_link));
[Idx_1to1_end Idx_1to1_start] = find(gate_link);
Idx_0to1 = (1:usedID)'; %every branch can be the first branch.
Idx_1to0 = (1:usedID)'; %every branch can be the last branch.

%define the cost C matrix and the probability P vector
nEle = 2*usedID;
nHypo_0to1 = length(Idx_0to1);
nHypo_1to0 = length(Idx_1to0);
nHypo_1to1 = length(Idx_1to1_end);
nHypo = nHypo_0to1 + nHypo_1to0 + nHypo_1to1;
C = zeros(nHypo, nEle);
%           1_e 2_e ... usedID_e, 1_s 2_s ... usedID_s
% Hypo_0to1
% Hypo_1to0
% Hypo_1to1

%Case: 0 to 1 %first branch
lidx_0to1 = (usedID+Idx_0to1-1)*nHypo + (1:nHypo_0to1)';
C(lidx_0to1) = 1;
P_0to1 = 10*ones(nHypo_0to1,1);

%Case: 1 to 0 %last branch
lidx_1to0 = (Idx_1to0-1)*nHypo + ((nHypo_0to1+1):(nHypo_0to1+nHypo_1to0))';
C(lidx_1to0) = 1;
P_1to0 = 10*ones(nHypo_1to0,1);

%Case: 1 to 1 %migration
tmp = ((nHypo_0to1+nHypo_1to0+1):(nHypo_0to1+nHypo_1to0+nHypo_1to1))';
lidxMig_end = (Idx_1to1_end-1)*nHypo + tmp;
lidxMig_start = (usedID+Idx_1to1_start-1)*nHypo + tmp;
C([lidxMig_end; lidxMig_start]) = 1;
lidx = sub2ind([usedID, usedID],Idx_1to1_end, Idx_1to1_start);
P_1to1 = dist_S(lidx)/g_distThre_S-dist_T(lidx)/g_distThre_T;

P = double([P_0to1; P_1to0; P_1to1]);

%solve the optimization
%tic
%[x,~,exitflag] = bintprog(P,[],[],C',ones(nEle,1),[],options); %strict optimization
%toc
lb = zeros(nHypo,1);
ub = ones(nHypo,1);
intcon = 1:nHypo;
x = intlinprog(P,intcon,[],[],C',ones(nEle,1),lb,ub);

%link branches (depth-first search)
matchedInd = find(x(nHypo_0to1+nHypo_1to0+1:nHypo_0to1+nHypo_1to0+nHypo_1to1)==1);
matches = [Idx_1to1_end(matchedInd) Idx_1to1_start(matchedInd)]; %[ID_e ID_s]
nLinkedBranches = sum(x(1:nHypo_0to1));
linkedBranchinfo(1:nLinkedBranches) = struct('frame',[0 0], 'pos',zeros(g_nFrames,2));
ID = 0;
for ii = 1:nHypo_0to1
    if x(ii)==0; continue; end
    eidx = Idx_0to1(ii); %the index of original BigBranchInfo
    ID = ID + 1;
    linkedBranchinfo(ID).frame = BigBranchInfo(eidx).frame;
    linkedBranchinfo(ID).pos = BigBranchInfo(eidx).pos;
    
    ind = find(matches(:,1)==eidx);
    while ~isempty(ind)
        sidx = matches(ind,2);
        
        eFrame = linkedBranchinfo(ID).frame(2);
        sFrame = BigBranchInfo(sidx).frame(1);
        ePos = linkedBranchinfo(ID).pos(end,:);
        sPos =  BigBranchInfo(sidx).pos(1,:);
        time = eFrame+1:sFrame-1;
        xx = interp1([eFrame sFrame], [ePos(1) sPos(1)], time)';
        yy = interp1([eFrame sFrame], [ePos(2) sPos(2)], time)';
        
        linkedBranchinfo(ID).frame(2) = BigBranchInfo(sidx).frame(2);
        linkedBranchinfo(ID).pos = [linkedBranchinfo(ID).pos; [xx yy]; BigBranchInfo(sidx).pos];
        
        ind = find(matches(:,1)==sidx);
    end
end

%trucation
for ii = 1:nLinkedBranches
    len = linkedBranchinfo(ii).frame(2)-linkedBranchinfo(ii).frame(1)+1;
    linkedBranchinfo(ii).pos = linkedBranchinfo(ii).pos(1:len,:);
end

save(sprintf('%s\\linkedBranchinfo_%s.mat',VideoPath,VideoName),'linkedBranchinfo');

