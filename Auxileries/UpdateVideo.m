function UpdateVideo(h, J, I_stable, vidobjWR1, vidobjWR2)

F = getframe(h);
writeVideo(vidobjWR1,F);

J_zoom2 = imcrop(imresize_old(J,2),[size(J,1)/2 size(J,2)/2 size(J,1)-1 size(J,2)-1]);
I_stable_zoom2 = imcrop(imresize_old(I_stable,2),[size(I_stable,1)/2 size(I_stable,2)/2 size(I_stable,1)-1 size(I_stable,2)-1]);
writeVideo(vidobjWR2,[J_zoom2 I_stable_zoom2]);