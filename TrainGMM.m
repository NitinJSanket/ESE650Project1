% ImgNames = dir('Training_set/*.png');

%% Get Masks
% for i = 1:length(ImgNames)
%    ImgNow = imread(['Training_set/',ImgNames(i).name]);
%    MaskNow = roipoly(ImgNow);
%    imwrite(MaskNow,['Masks/M',ImgNames(i).name]);
% end

%% Refine Masks
% Name = '4.5';
% MaskNow = imread(['Masks/M',Name,'.png']);
% ImgNow = imread(['Training_set/',Name,'.png']);
% Mask2 = roipoly(RGBMask(im2double(ImgNow), im2double(MaskNow), 1));
%
% MaskNow = MaskNow | Mask2;
% imwrite(MaskNow,['Masks/M',Name,'.png']);


%% Get All the datapoints
disp('Reading Images For Training....');
ImgNames = dir([TrainImgPath,'/*.png']);
RGBVals = [];
for i = 1:length(ImgNames)
    ImgNow = im2double(imread([TrainImgPath,'/',ImgNames(i).name]));
    if(strcmp(ColorSpace,'YCbCr'))
        ImgNow = rgb2ycbcr(ImgNow);
    elseif(strcmp(ColorSpace,'rYb'))
        ImgNow = RGChromacity(ImgNow);
    elseif(strcmp(ColorSpace,'RGB'))
        % Keep RGB as it is.
    else
        error('Enter Valid Color Space: YCbCr or rYb or RGB');
    end
    
    
    MaskNow = im2double(imread([TrainMaskPath,'/M',ImgNames(i).name]));
    Stats = regionprops(MaskNow, 'PixelList'); % Returns X and Y
    MaskedImg = RGBMask(ImgNow,MaskNow,0);
    R = MaskedImg(:,:,1);
    G = MaskedImg(:,:,2);
    B = MaskedImg(:,:,3);
    
    RGBVals = [RGBVals; [R(MaskNow>0),G(MaskNow>0),B(MaskNow>0)]];
    disp(['Image ', num2str(i), ' of ', num2str(length(ImgNames)),' done....']);
end

disp('Image Reading Done....');
%% Fit a GMM
NumClasses = 2;
K = 7; % Number of Gaussians
NumChannels = size(RGBVals,2);
NumVals = size(RGBVals,1);
MeanPrev = zeros(NumChannels,K); % Previous gaussian means

% Random Initialization
% Mean = rand(NumChannels,K); % All the gaussian means
% Mean = mean(RGBVals,1)';
% Mean = repmat(Mean,1,K)+0.8.*rand(NumChannels,K);
% Mean(Mean>1) = 1.0;
% % Might want to check if det becomes zero
% % Has to be a PSD
% A = rand(NumChannels,NumChannels,K); % A matrix, i.e., inv(Cov)
% for k = 1:K
%     A(:,:,k) = A(:,:,k)'*A(:,:,k); % To make it a PSD
% end

% Use K-Means to Initialize
[Labels,Mean] = kmeans(RGBVals,K);
for k = 1:K
    A(:,:,k) = cov(RGBVals(Labels==k,:));
end
Mean = Mean'; % Matlab's K means is transpose of the Means I have
Mixture Coeff
GMMC = 1./K.*ones(1,K);

RGBValsStacked = repmat(RGBVals, 1,1,K);
MeanStacked = reshape(Mean,1,NumChannels,K);

if(strcmp(ColorSpace,'YCbCr'))
    Thld = 1e-4;
elseif(strcmp(ColorSpace,'rYb'))
    Thld = 1e-3; % Thld to stop iterations
elseif(strcmp(ColorSpace,'RGB'))
    Thld = 1e-4;
else
    error('Enter Valid Color Space: YCbCr or rYb or RGB');
end

NIter = 1000;
Frames = cell(NIter,1);

disp('GMM Initialization Done....');
for iter = 1:NIter
    Mean = real(Mean);
    A = real(A);
    disp(iter);
    PlotGMM(A,Mean,RGBVals,0,0);
    title(iter);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    pause(0.5);
    
    % E - Step
    for k = 1:K
        ANow = A(:,:,k);
        NormFac = 1./((2*pi)^(NumChannels/2)*sqrt(det(inv(ANow))));
        RGBMeanCentered = bsxfun(@minus,RGBVals',Mean(:,k));
        P(:,k) = NormFac*exp(-0.5.*(RGBMeanCentered(1,:)'.*(RGBMeanCentered'*ANow(:,1)) +...
            RGBMeanCentered(2,:)'.*(RGBMeanCentered'*ANow(:,2)) +  RGBMeanCentered(3,:)'.*(RGBMeanCentered'*ANow(:,3))));
    end
    
    % Account for mixture coeff
    P = bsxfun(@times, P, GMMC)+eps; % This is the mixture coeff
    % Normalize P to find Alpha
    Alphas = bsxfun(@rdivide,P,sum(P,2));
    
    % M - Step
    
    % Update Mean
    Mean = bsxfun(@rdivide,squeeze(sum(bsxfun(@times, RGBValsStacked, reshape(Alphas, size(Alphas,1),1,size(Alphas,2))),1)),...
        sum(Alphas,1));
    
    % Update Covariance and hence A
    RGBMeanCentered = bsxfun(@minus,reshape(RGBVals,NumVals,NumChannels,1,1),reshape(Mean,1,NumChannels,1,K));
    XXTrans = bsxfun(@times, reshape(RGBMeanCentered,NumVals,NumChannels,1,K), reshape(RGBMeanCentered,NumVals,1,NumChannels,K));
    AlphaXXTrans = bsxfun(@times, XXTrans,reshape(Alphas,NumVals,1,1,K));
    AlphaXXTransMean = squeeze(sum(AlphaXXTrans,1)); % Sum per cluster
    SumAlphas = sum(Alphas,1); % Denominator Term
    Cov = bsxfun(@rdivide, AlphaXXTransMean,reshape(SumAlphas,1,1,K)); % Divide by denominator term for each cluster
    
    for k = 1:K
        A(:,:,k) = inv(Cov(:,:,k));
    end
    
    % Update mixture coeff
    GMMC = sum(Alphas,1)./NumVals;
    
    disp(Mean);
    disp(norm(Mean-MeanPrev));
    if(norm(Mean-MeanPrev) < Thld && iter > 1)
        break;
    end
    
    MeanPrev = Mean;
    
end

disp('GMM Training Done....');

Mean = real(Mean);
A = real(A);

save(['GMM',ColorSpace,'K7KMeansInit.mat']);
disp(['GMM Model Saved as: GMM',ColorSpace,'K7KMeansInit.mat ....']);