%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Color Segmentation on YCbCr color space using GMM for ESE 650 Project 1
%% Written By: Nitin J. Sanket (nitinsan@seas.upenn.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all
warning off;
addpath(genpath('./imFeretDiameters'));

TrainImgPath = '../../../../Training_set/';
TrainMaskPath = '../../../../Masks/';
TestImgsPath = './';

% If you want to train enable this flag
TrainFlag = 1;
% Feed the color-space name here
% YCbCr or rYb or RGB
ColorSpace = 'YCbCr';
disp(['Using ColorSpace ',ColorSpace]);

%% Train the GMM
if(TrainFlag)
    TrainGMM;
else
    load(['GMM',ColorSpace,'K7KMeansInit.mat']);
    disp('GMM Model Loaded....');
end

load('ModelWH.mat');
%% Testing
disp('Testing Started....');
TestImgs = dir([TestImgsPath,'/*.png']);

for i = 1:length(TestImgs)
    tic
    clf;
    disp(['Processing Image ',num2str(i),' of ', num2str(length(TestImgs))]);
    I = (im2double(imread([TestImgsPath,'/',TestImgs(i).name])));
    
    IRGB = I;
    if(strcmp(ColorSpace,'YCbCr'))
        I = rgb2ycbcr(I);
    elseif(strcmp(ColorSpace,'rYb'))
        I = rYbhromacity(I);
    elseif(strcmp(ColorSpace,'RGB'))
        % Keep I as it is.
    else
        error('Enter Valid Color Space: YCbCr or rYb or RGB');
    end
    
    IR = I(:,:,1);
    IR = IR(:);
    IG = I(:,:,2);
    IG = IG(:);
    IB = I(:,:,3);
    IB = IB(:);
    
    %     %% Compute Using GMM Output for probabilties
    % Loop over clusters
    PXGivenC = zeros(size(IR));
    
    for k = 1:K
        ANow = A(:,:,k);
        NormFac = 1./((2*pi)^(NumChannels/2)*sqrt(det(inv(ANow))));
        RGBMeanCentered = bsxfun(@minus,[IR, IG, IB]',Mean(:,k));
        PXGivenC = PXGivenC + GMMC(k)*NormFac*exp(-0.5.*(RGBMeanCentered(1,:)'.*(RGBMeanCentered'*ANow(:,1)) +...
            RGBMeanCentered(2,:)'.*(RGBMeanCentered'*ANow(:,2)) +  RGBMeanCentered(3,:)'.*(RGBMeanCentered'*ANow(:,3))));
    end
    
    PXGivenC = reshape(PXGivenC, [size(I,1), size(I,2)]);
    
    % Control Hard Thld of 100 to see if there is no barrel
    PXGivenCMask = PXGivenC>=0.005*max(max(PXGivenC));% & PXGivenC >= 100
    
    if(~any(any(PXGivenC))) % Nothing was found
        disp('No Barrel Found, Blobs Rejected in Thresholding....');
        continue;
    end
    
    PXGivenCFinal = PXGivenC;
    PXGivenCFinalMask = PXGivenCMask;
    [OBB, MaskBlobs, MaskFull] = FilterOutput(PXGivenCFinalMask);%bwconvhull(PXGivenCFinalMask,'objects')
    
    if(isempty(OBB)) % Nothing was found
        continue;
    end
    
    ModMaskFull = zeros(size(MaskFull));
    MaskFullL = bwlabel(MaskFull);
    StatsAll = regionprops(MaskFullL,'All');
    
    for j = 1:size(OBB,1)
        V{j} = ComputeOrientedBoxPoints(OBB(j,:));
        ModMask = zeros(size(MaskFull));
        for q = 1:size(V{j},1)
            ModMask(round(V{j}(q,2)),round(V{j}(q,1))) = 1;
        end
        if(sum(sum(bwconvhull(ModMask).*MaskFull))/sum(sum(bwconvhull(ModMask)))>=0.53)
            ModMaskFull = ModMaskFull | bwconvhull(ModMask);
        end
    end
    
    
    %     %% Compute Depth and Number of Barrels
    ModMaskFullL = bwlabel(ModMaskFull);
    OBB = imOrientedBox(ModMaskFullL);
    OBB = [OBB, zeros(size(OBB,1),1)];
    NumSeg = max(max(ModMaskFullL));
    % Reject Blobs based on Aspect Ratio
    for q = 1:size(OBB,1)
        % If not in aspect ratio range of the barrel, remove the blob
        if(~(min(OBB(q,3:4))./max(OBB(q,3:4))<=0.92 && min(OBB(q,3:4))./max(OBB(q,3:4))>=0.38))
            OBB(q,6) = 1;
            for w = 1:NumSeg
                ModMaskFull = ModMaskFull & ~(ModMaskFullL==ModMaskFullL(round(OBB(q,2)),round(OBB(q,1))));
            end
        end
    end
    
    NumBarrels(i) = size(OBB,1);
    disp([num2str(NumBarrels(i)), ' Barrel(s) Found']);
    
    for q = 1:NumBarrels(i)
        HNow = OBB(q,3);
        WNow = OBB(q,4);
        AreaNow = OBB(q,3).*OBB(q,4);
        %         DistNow(q) = [1./WNow, 1./HNow, 1./AreaNow]*Model;
        DistNow(q) = [1, 1./WNow, 1./HNow]*Model;
        DistNow(q) = DistNow(q).*1.03;
        OrientationNow(q) = OBB(q,5);
        disp([DistNow(q), OrientationNow(q)]);
    end
    
    IDisp = PlotMaskOnRGB(IRGB, PXGivenCMask,[1,1,0]);
    IDisp = PlotMaskOnRGB(IDisp, MaskFull,[0,1,0]);
    IDisp = PlotBoxOnRGB(IDisp,ModMaskFull,[1, 0, 0]);
    imshow(IDisp);
    hold on;
    for q = 1:NumBarrels(i)
        if(OBB(q,6)==0)
            plot(OBB(q,1),OBB(q,2),'r*');
            text(OBB(q,1)+50, OBB(q,2), ...
                sprintf(['Dist:',num2str(DistNow(q)),'m\nOrientation:'...
                , num2str(OBB(q,5))]),'FontSize',16,'Color','r','BackgroundColor','w');
        end
    end
    toc
    disp('Press Enter on the Command Line to Continue....');
    pause(0.1);
    
    DistAll{i} = DistNow;
    OrientationAll{i} = OrientationNow;
    
    saveas(gcf,['Outputs/Out',TestImgs(i).name]);
end

