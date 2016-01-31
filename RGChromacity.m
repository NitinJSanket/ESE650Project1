function RGC = RGChromacity(I)
    IR = I(:,:,1);
    IG = I(:,:,2);
    IB = I(:,:,3);
    
    IRGB = IR+IG+IB;
    
    r = IR./IRGB;
    g = IG./IRGB;
    b = IB./IRGB;
    
    YCbCr = rgb2ycbcr(I);

    RGC = cat(3,r,YCbCr(:,:,3),b);
end