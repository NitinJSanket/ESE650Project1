function [Io] = EdgesOnColor(I, ChannelNo, BW)
AllChannels = [1,2,3];
AllChannels = setdiff(AllChannels, ChannelNo);
Temp1 = I(:,:,ChannelNo);
Temp1(BW==1) = 1;
Temp2 = I(:,:,AllChannels(1));
Temp2(BW==1) = 0;
Temp3 = I(:,:,AllChannels(2));
Temp3(BW==1) = 0;
Io(:,:,ChannelNo) = Temp1;
Io(:,:,AllChannels(1)) = Temp2;
Io(:,:,AllChannels(2)) = Temp3;
% imshow(Io); pause;
% tI = I(:,:,ChannelNo);
% tI(BW>0) = 1;
% Io(:,:,ChannelNo) = tI;
% Io(:,:,AllChannels(1)) = I(:,:, AllChannels(1));
% Io(:,:,AllChannels(2)) = I(:,:, AllChannels(2));
end