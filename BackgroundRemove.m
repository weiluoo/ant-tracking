clc
clear all;
FilePathAndNameInit



im4=imread(sprintf('%s\\frame%06d.jpg',OrigPath,g_start_frame));
bkgd=zeros(size(im4,1),size(im4,2));
parfor frameidx=g_start_frame:g_frame_interval:g_end_frame
    im4=double(imread(sprintf('%s\\frame%06d.jpg',OrigPath,frameidx)));
    bkgd=bkgd+im4(:,:,1);
    frameidx
end
bkgd=bkgd*g_frame_interval/(g_end_frame-g_start_frame);

parfor frameidx=g_start_frame:g_frame_interval:g_end_frame
    im4=imread(sprintf('%s\\frame%06d.jpg',OrigPath,frameidx));
    chn1=im4(:,:,1);%chn2pp=single(chn2pp);
    %         chn2=im4(:,:,2);%chn2pp=single(chn2pp);
    %         chn3=im4(:,:,3);%chn2pp=single(chn2pp);
    %imshow(chn1);
    mask=bkgd-double(chn1)>30;
    %         tmp2=chn2<60;
    %         tmp3=chn3<60;
    
    
    %         mask=(tmp1&tmp2&tmp3);
    %         mask=tmp1-bkgd;
    mask2=bwareaopen(mask,20);
    %         mask3=imclose(mask2,SE);
    
    
    %         mask3=imopen(mask3,SE2);
    %         mask4=bwareaopen(mask3,30);
    %     mask4=imdilate(mask,SE2);
    %     mask2=imopen(mask,SE);  %remove penisulas and bridges
    %     mask3=bwareaopen(mask2,130);
    
    
    file_name=sprintf('%s\\frame%06d.jpg',SegPath,frameidx)
    imwrite(mask2,file_name);
%     imwrite(mask,file_name);
end