function I = PlotMaskOnRGB(I,Mask,Color)
if(nargin<3)
    Color = [0,1,0]; % Default color is green
end

IR = I(:,:,1);
IG = I(:,:,2);
IB = I(:,:,3);
IR(Mask) = Color(1);
IG(Mask) = Color(2);
IB(Mask) = Color(3);
I = cat(3, IR, IG, IB);

end