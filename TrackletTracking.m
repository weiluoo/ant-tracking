clc
clear all;
FilePathAndNameInit

figure(1);
debug = 0;

maxbranches = 10000;
branchinfo(1:maxbranches) = struct('frame',[0 0], 'pos',zeros(g_nFrames,2));
usedID = 0; %the ID used so far



for iFrame = g_start_frame:g_frame_interval:g_end_frame
     
    load(sprintf('%s\\posInfo%06d.mat',PosPath,iFrame),'currPts');%,'currArea','num_interact');
    if isempty(currPts)
        continue;
    end
    
    nCurrPts = length(currPts(:,1));
    
    %nonmax suppression on nearby points
    labels = 1:nCurrPts;
    pos = currPts;
    %for ii = 1:nCurrPts
    %    dist2 = sum(( repmat(pos(ii,:),[nCurrPts-ii, 1]) - pos(ii+1:end,:) ).^2,2);
    %    labels(ii+find(dist2<=withinBagDist)) = labels(ii);
    %end
    %uniLabels = unique(labels); nUniLabels = length(uniLabels);
    %localMaxIdx = zeros(nUniLabels,1); count = 0;
    %for ii = 1:nUniLabels
    %    tmpIdx = find(labels==uniLabels(ii));
    %    [~,C] = max(currPts(tmpIdx).Metric);
    %    count = count + 1;
    %    localMaxIdx(count) = tmpIdx(C);
    %end
    %localMaxIdx = localMaxIdx(1:count);
    %     currPts = currPts(localMaxIdx);
    %     nCurrPts = length(currPts);
    
    %initialize the tracker
    if iFrame == g_start_frame
        for jj = 1:nCurrPts
            branchinfo(jj).frame = [iFrame iFrame];
            branchinfo(jj).pos(1:20,:) = repmat(currPts(jj,:),[20,1]);
        end
        usedID = usedID + nCurrPts;
        prevPts = currPts;
        nPrevPts = nCurrPts;
        %         prevFeatures = features;
        prevIDs = (1:nPrevPts)';
%         if debug
%             showAntsOfCurFrame(iFrame,currPts);
%         end
        continue;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %tracking by LAP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %compute the gating regions
    gate_dist = (repmat(currPts(:,1), [1 nPrevPts])-repmat(prevPts(:,1)', [nCurrPts 1])).^2+...
        (repmat(currPts(:,2), [1 nPrevPts])-repmat(prevPts(:,2)', [nCurrPts 1])).^2<=g_distThre_S;
    %gate_signOfLaplacian = repmat(currPts.SignOfLaplacian, [1 nPrevPts])==repmat(prevPts.SignOfLaplacian', [nCurrPts 1]);
    [Idx_1to1_currPts Idx_1to1_prevPts] = find(gate_dist);
    Idx_1to1_currPts=Idx_1to1_currPts(:);
    Idx_1to1_prevPts=Idx_1to1_prevPts(:);
    Idx_0to1 = (1:nCurrPts)'; %every current point can be a new point.
    Idx_1to0 = (1:nPrevPts)'; %every previous point can disappear.
    
    %define the cost C matrix and the probability P vector
    nEle = nPrevPts + nCurrPts;
    nHypo_0to1 = length(Idx_0to1);
    nHypo_1to0 = length(Idx_1to0);
    nHypo_1to1 = length(Idx_1to1_currPts);
    nHypo = nHypo_0to1 + nHypo_1to0 + nHypo_1to1;
    C = zeros(nHypo, nEle);
    %           prevPts    currPts
    % Hypo_0to1
    % Hypo_1to0
    % Hypo_1to1
    
    %Case: 0 to 1 %appear
    lidx_0to1 = (nPrevPts+Idx_0to1-1)*nHypo + (1:nHypo_0to1)';
    C(lidx_0to1) = 1;
    P_0to1 = 1*ones(nHypo_0to1,1);
    
    %Case: 1 to 0 %disappear
    lidx_1to0 = (Idx_1to0-1)*nHypo + ((nHypo_0to1+1):(nHypo_0to1+nHypo_1to0))';
    C(lidx_1to0) = 1;
    P_1to0 = 1*ones(nHypo_1to0,1); %xrh from 100 to 1
    
    %Case: 1 to 1 %migration
    tmp = ((nHypo_0to1+nHypo_1to0+1):(nHypo_0to1+nHypo_1to0+nHypo_1to1))';
    
    lidxMig_prevPts = (Idx_1to1_prevPts-1)*nHypo + tmp;
    lidxMig_currPts = (nPrevPts+Idx_1to1_currPts-1)*nHypo + tmp;
    C([lidxMig_prevPts; lidxMig_currPts]) = 1;
    dist = sum((prevPts(Idx_1to1_prevPts,:)-currPts(Idx_1to1_currPts,:)).^2,2);%xrh add
    P_1to1 = dist/max(dist);%xrh add divide to fomulate P_1to1 to 1
    %     P_1to1 = sum((prevFeatures(Idx_1to1_prevPts,:)-features(Idx_1to1_currPts,:)).^2,2);
    
    P = double([P_0to1; P_1to0; P_1to1]);
    
    %solve the optimization
    %[x,~,exitflag] = bintprog(P,[],[],C',ones(nEle,1),[],options); %strict optimization
    lb = zeros(nHypo,1);
    ub = ones(nHypo,1);
    intcon = 1:nHypo;
    x = intlinprog(P,intcon,[],[],C',ones(nEle,1),lb,ub);
    
    
    %grow branches
    if debug
        showCurrentlyExistedAntsInBranch(branchinfo,iFrame-1);
        %Case: 0 to 1 %appear
        for ii = 1:nHypo_0to1
            if x(ii)==0; continue; end
            idx = Idx_0to1(ii); %idx in currPts
            if debug
                plot(currPts(idx,1),currPts(idx,2),'+','Linewidth',1,'Markersize',5,'Color','b');  
                text(currPts(idx,1),currPts(idx,2)+10,sprintf('%d',idx),'Color','b');
            end        
        end
        %Case: 1 to 0 %disappear
         for ii = nHypo_0to1+1:nHypo_0to1+nHypo_1to0
            if x(ii)==0; continue; end
            idx = Idx_1to0(ii-nHypo_0to1); %idx in prevPts;
            Id = prevIDs(idx);
            if debug
                nFrames = branchinfo(Id).frame(2) - branchinfo(Id).frame(1);
                plot(branchinfo(Id).pos(nFrames+1,1),branchinfo(Id).pos(nFrames+1,2),'*','Linewidth',1,'Markersize',5,'Color','r');            
            end
         end
    %      pause
    end
    
    currIDs = zeros(nCurrPts,1);
    %Case: 0 to 1 %appear
    for ii = 1:nHypo_0to1
        if x(ii)==0; continue; end
        idx = Idx_0to1(ii); %idx in currPts
        usedID = usedID + 1;
        branchinfo(usedID).frame = [iFrame iFrame];
        branchinfo(usedID).pos(1:g_frame_interval,:) = repmat(currPts(idx,:),[g_frame_interval,1]); %xrh from 20 to g_frame_interval
%         if debug
%             showAppearedAnts(iFrame,currPts(idx,:));
%         end
        currIDs(idx) = usedID;
    end
    
    %Case: 1 to 0 %disappear
    for ii = nHypo_0to1+1:nHypo_0to1+nHypo_1to0
        if x(ii)==0; continue; end
        idx = Idx_1to0(ii-nHypo_0to1); %idx in prevPts;
        Id = prevIDs(idx);
        branchinfo(Id).frame(2) = iFrame - 1;
    end
    
    %Case: 1 to 1 %migration
    for ii = nHypo_0to1+nHypo_1to0+1:nHypo_0to1+nHypo_1to0+nHypo_1to1
        if x(ii)==0; continue; end
        tii = ii - nHypo_0to1 - nHypo_1to0;
        pIdx = Idx_1to1_prevPts(tii);
        Id = prevIDs(pIdx);
        branchinfo(Id).frame(2) = iFrame;
        idx = iFrame-branchinfo(Id).frame(1)+1;
        cIdx = Idx_1to1_currPts(tii);
        branchinfo(Id).pos(idx:idx+g_frame_interval-1,:) = repmat(currPts(cIdx,:),[g_frame_interval,1]);%xrh from 19 to g_frame_interval-1,20 to g_frame_interval
        currIDs(cIdx) = Id;
    end
    
    %update for the next frame
    prevPts = currPts;
    nPrevPts = nCurrPts;
    %     prevFeatures = features;
    prevIDs = currIDs;
    
%    disp([num2str(iFrame) ': ' num2str(cputime-tt)]);
end

branchinfo = branchinfo(1:usedID); %trucation
save(sprintf('%s\\branchInfo_%s.mat',VideoPath,VideoName),'branchinfo');