function showAppearedAnts(iFrame,pos)
global g_frame_interval;
key = 'y'
%iFrame = 1;
%pos = [3 5]; 
while(key == 'y')
    imag = ImageRead('Seg',iFrame-g_frame_interval);
    imshow(imag,[]);
    hold on;
    iFrame
    disp('press any key to continue...\r\n');
    pause;
    imag = ImageRead('Seg',iFrame);
    imshow(imag,[]);
    
    plot(pos(1),pos(2),'o','Linewidth',1,'Markersize',5,'Color','g');
    drawnow;
    key = input('continue?y/n:[y]','s');
    if isempty(key)
          key = 'y';
    end
    
end
end