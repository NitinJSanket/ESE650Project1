function [OBB,MaskBlobs, RefinedMask] = FilterOutput(I)
IL = bwlabel(I);
Stats = regionprops(IL,'All');
Idxs = find([Stats.Area]>=0.22.*max([Stats.Area]) & [Stats.Solidity]>=0.6.*max([Stats.Solidity]));
Mask = ismember(IL,Idxs);
Mask = imerode(Mask,strel('disk',2,8));
Mask = bwmorph(Mask,'spur');
Mask = bwmorph(Mask,'branchpoints');
Mask = imdilate(Mask,strel('disk',6,8));
Stats = regionprops(Mask,'All');
Idxs = find([Stats.Area]>=0.22.*max([Stats.Area]) & [Stats.Solidity]>=0.6.*max([Stats.Solidity]));
Mask = ismember(bwlabel(Mask),Idxs);


%% If No Object Return
if(~any(any(Mask)))
    disp('No Barrel Found, Blobs Rejected in Filtering....');
    RefinedMask = zeros(size(I));
    MaskBlobs = cell(0);
    OBB = [];
    return;
end

%% Combine Maks if they are very close
DistThld = 150;
IL = bwlabel(Mask);
Stats = regionprops(IL, 'All');
RefinedMask = zeros(size(Mask));
for i = 1:size(Stats,1)-1
    for j = i+1:size(Stats,1)
        % Compute Distance between ith and jth
        Dist = pdist2(Stats(i).Centroid,Stats(j).Centroid);
        if(Dist<=DistThld)
            TempMask = (IL==i) | (IL==j);
            TempSolidity = sum(sum(TempMask))./sum(sum(bwconvhull(TempMask)));
            if(TempSolidity>=0.85)
                RefinedMask = RefinedMask | bwconvhull(TempMask);
            end
        else
            RefinedMask = RefinedMask | bwconvhull(IL==i) | bwconvhull(IL==j);
        end
    end
end

% If you had only 2 pieces
if(size(Stats,1)==2)
    if(Dist>DistThld)
        RefinedMask = bwconvhull(Mask,'objects');
    else
        if(sum(sum(Mask))./sum(sum(bwconvhull(Mask)))>=0.85)
            RefinedMask = bwconvhull(Mask);
        else
           RefinedMask = bwconvhull(Mask,'objects');
        end
    end
end

% If you couldnt group any values use the original Mask itself
if(~any(any(RefinedMask)))
    RefinedMask = Mask;
end


%% Correct Rotation of the Box
IL = bwlabel(RefinedMask);
OBB = imOrientedBox(IL);
for i = 1:size(OBB,1)
    MaskBlobs{i} = rotateAround(IL==i, OBB(i,2), OBB(i,1), -OBB(i,5)+90, 'bicubic');
end

end