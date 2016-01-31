function V = ComputeOrientedBoxPoints(box)

cx  = box(:,1);
cy  = box(:,2);
hl   = box(:,3) / 2;
hw   = box(:,4) / 2;
theta = box(:,5);


%% Draw each box
VX = [];
VY = [];

% iterate on oriented boxes
for i = 1:length(cx)
    % pre-compute angle data
    cot = cosd(theta(i));
    sit = sind(theta(i));
    
    % x and y shifts
    lc = hl(i) * cot;
    ls = hl(i) * sit;
    wc = hw(i) * cot;
    ws = hw(i) * sit;
    
    % coordinates of box vertices
    vx = cx(i) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws ; -lc + ws];
    vy = cy(i) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc ; -ls - wc];
    
    VX = [VX, vx];
    VY = [VY, vy];
end

V = [VX, VY];

end
