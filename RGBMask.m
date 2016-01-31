function Masked = RGBMask(ImgNow, MaskNow, NegateFlag)
if(nargin<3)
    NegateFlag = 0;
end

if(NegateFlag)
    MaskNow = ~MaskNow;
end
Masked(:,:,1) = ImgNow(:,:,1).*MaskNow;
Masked(:,:,2) = ImgNow(:,:,2).*MaskNow;
Masked(:,:,3) = ImgNow(:,:,3).*MaskNow;
end