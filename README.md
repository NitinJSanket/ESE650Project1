# Colored Barrel Detection Using Gaussian Mixture Model based Color Segmentation

## Problem Statement
Given a set of training images in the folder [Train](Train) with the file names as the distance to the barrel in meters, find the distance to all the barrels in each [Test](Test) image.

## Usage Guide:
1.  Run `Wrapper.m`
2. Change ColorSpace by changing `ColorSpace` variable to any one of `RGB` or `YCbCr` or `yRb`. The code thresholds currently work for YCbCr.
3. To train, Set `TrainFlag = 1`, switched off by default. 
4. If you have any questions or queries feel free to raise an issue.

## Sample Input and Outputs:
![Input](Test/001.png)![Output](TestOutputs/YCbCr1.jpg)
![Input](Test/002.png)![Output](TestOutputs/YCbCr2.jpg)
![Input](Test/003.png)![Output](TestOutputs/YCbCr3.jpg)
![Input](Test/004.png)![Output](TestOutputs/YCbCr4.jpg)

## GMM Covariance while being trained:
<a href="http://www.youtube.com/watch?feature=player_embedded&v=ynWo76IzC_U
" target="_blank"><img src="http://img.youtube.com/vi/ynWo76IzC_U/0.jpg" 
alt="GMM Training Video" width="240" height="180" border="10" /></a>

## Reference Codes:
1. Oriented Bounding Box http://www.mathworks.com/matlabcentral/fileexchange/30402-feret-diameter-and-oriented-box/content/imFeretDiameters/imFeretDiameter.m
2. Ellipsoid Plotting http://www.mathworks.com/matlabcentral/fileexchange/13844-plot-an-ellipse-in--center-form-
3. Entropy rate segmentation http://www.merl.com/publications/docs/TR2011-035.pdf

