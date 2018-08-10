function showAntsOfCurFrame(iFrame,currPts)
    global VideoPath;
    imag = ImageRead(VideoPath,'Seg',iFrame);
    imshow(imag,[]);
    hold on;
    %iFrame
    text(10,size(imag,1)/2,int2str(iFrame),'Color','g');
    
    for i= 1:length(currPts)
        plot(currPts(i,1),currPts(i,2),'o','Linewidth',1,'Markersize',5,'Color','g');  
    end
    
    %disp('press any key to continue...\r\n');
    %pause;
end