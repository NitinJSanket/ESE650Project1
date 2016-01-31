function PlotGMM(A,Mean,RGBVals,WriteFlag,PointFlag)
clf;
PlotAllEllipses(A, Mean);
if(PointFlag)
    hold on;
    plot3(RGBVals(:,1),RGBVals(:,2),RGBVals(:,3),'r.');
    hold off;
end
grid on;
axis square;
if(WriteFlag)
    Frames{iter} = getframe(gcf);
    imwrite(Frames{iter}.cdata,[num2str(iter),'.png']);
end
end