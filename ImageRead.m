function img = ImageRead(videopath,subfold,frameidx)
    
    filename = sprintf('%s\\%s\\frame%06d.jpg',videopath,subfold,frameidx);
    img = imread(filename);

end