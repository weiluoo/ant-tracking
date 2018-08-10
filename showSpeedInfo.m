clc
clear all;
FilePathAndNameInit

load(sprintf('%s\\speedInfo_%s.mat',VideoPath,VideoName),'vec_speed','vec_movement','vec_activeant','vec_fastant');

figure
subplot(3,1,1);
plot(vec_speed);
title('speed');
subplot(3,1,2);
plot(vec_activeant);
title('activeant');
subplot(3,1,3);
plot(vec_fastant);
title('fastant');