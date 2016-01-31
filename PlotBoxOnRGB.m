function I = PlotBoxOnRGB(I,Mask,Color)
if(nargin<3)
    Color = [1,0,0]; % Default Red
end
% Get Perimeter Pixels
Mask = bwperim(Mask,8);
% Make the box a bit thicker
Mask = imdilate(Mask, strel('disk',2));

IR = I(:,:,1);
IG = I(:,:,2);
IB = I(:,:,3);
IR(Mask) = Color(1);
IG(Mask) = Color(2);
IB(Mask) = Color(3);
I = cat(3, IR, IG, IB);

end