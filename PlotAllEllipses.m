function PlotAllEllipses(A, C)
hold on;
for i = 1:size(C,2)      
    Ellipse_plot(A(:,:,i), C(:,i));
end
hold off;
end