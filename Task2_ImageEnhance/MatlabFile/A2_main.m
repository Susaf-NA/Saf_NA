% Image Enhancement
% By: Susaf N.A
% Computer Vision Class
% February 2020 MTI UGM

%% Inizialization and data acquisition
clc; %clearing command window
clear all; close all;  %clear all variable and close all window
fontSize = 30; %label font size

% load image name with the extention type
%filename = 'img_1.png'; 
%filename = 'img_2.png';
filename = 'img_3.png';

% Read in indexed image.
[imgOri, storedColorMap] = imread(filename);
[rows, columns, numberOfColorChannels] = size(imgOri);

% Checking if RGB indexed or not
if numberOfColorChannels <3 
    % Convert to RGB image by appying the colormap
    iRGB_Ori = ind2rgb(imgOri, storedColorMap);
else
    % Use original if already indexed
    iRGB_Ori = imgOri;
end

%% Data preprocessing

% separating by channel
% Extract the individual red, green, and blue color channels.
% int type
iRC_Ori = iRGB_Ori(:, :, 1); %integer Red Channel - Original value
iGC_Ori = iRGB_Ori(:, :, 2); %integer Green Channel - Original value
iBC_Ori = iRGB_Ori(:, :, 3); %integer Blue Channel - Original value

% double type
dRGB_Ori = im2double(iRGB_Ori);
dRC_Ori = dRGB_Ori(:,:,1); %double Red Channel - Original value
dGC_Ori = dRGB_Ori(:,:,2); %double Green Channel - Original value
dBC_Ori = dRGB_Ori(:,:,3); %double Blue Channel - Original value

%% Image Filtering
vf = [-1 2 -1; -1 2 -1; -1 2 -1]; %vertical filter
hf = [-1 -1 -1; 2 2 2; -1 -1 -1]; %horizontal filter

% vertical lines detection
dRC_vline = filter2(vf, dRC_Ori); %double Red Channel - vertical line
dGC_vline = filter2(vf, dGC_Ori);
dBC_vline = filter2(vf, dBC_Ori);
% horizontal lines detection
dRC_hline = filter2(hf, dRC_Ori); %double Red Channel - horizontal line
dGC_hline = filter2(hf, dGC_Ori);
dBC_hline = filter2(hf, dBC_Ori);

%% Creating Mask
% color treshold mask by calculate the value difference between channel
iRGC_diff = abs(int16(iRGB_Ori(:,:,1)) - int16(iRGB_Ori(:,:,2))); %integer Red-Green Channel - difference value
iRBC_diff = abs(int16(iRGB_Ori(:,:,1)) - int16(iRGB_Ori(:,:,3))); %integer Red-Blue Channel - difference value
iGBC_diff = abs(int16(iRGB_Ori(:,:,2)) - int16(iRGB_Ori(:,:,3))); %integer Green-Blue Channel - difference value
% detecting coloured (>30) and grayish pixel (<30)
mask_color = (iRGC_diff>20) | (iRBC_diff>30) | (iGBC_diff>20);
% detecting bright pixel (>200)
mask_bright = iRC_Ori>=200 & iGC_Ori>=200 & iBC_Ori>= 200;
% merge two mask
mask_color = mask_color | mask_bright; 

% line treshold mask
mask_line = (dRC_vline>0.4) | (dGC_vline>0.4) | (dBC_vline>0.4);
mask_hline = (dRC_hline>0.5) | (dGC_hline>0.5) | (dBC_hline>0.5);
mask_line = mask_line | mask_hline;
mask_all = mask_line | mask_color; %merge all mask

% increase masked area
m = [1 1 1; 1 1 1; 1 1 1]/9; %median value
nmask = filter2(m, mask_all);
mask_all = nmask>0.2;

%% Image Masking
imgRC_masked = dRC_Ori.*mask_all;
imgGC_masked = dGC_Ori.*mask_all;
imgBC_masked = dBC_Ori.*mask_all;
imgMasked = cat(3, imgRC_masked, imgGC_masked, imgBC_masked); %masked image

invfmask = ones(size(mask_all)) - mask_all; %inverse masked area
imgRC_masked_inv = dRC_Ori.*invfmask;
imgGC_masked_inv = dGC_Ori.*invfmask;
imgBC_masked_inv = dBC_Ori.*invfmask;
imgMasked_inv = cat(3, imgRC_masked_inv, imgGC_masked_inv, imgBC_masked_inv); %inverse of masked area

%% Show Masked Image
subplot(131);imshow(imgOri);
title('Original Image');
subplot(132);imshow(imgMasked);
title('Detected Artifacts');
subplot(133);imshow(imgMasked_inv);
title('Image without Artifacts');

%% Image Restoration

j = 1;

%testing different size of filter
%imgOut_comp = zeros(rows, columns, numberOfColorChannels, 6); 
%{
for i = 5%:4:25
    fsize = i;
    n = 100;
    imgOut = imageRestoration(imgMasked_inv,mask_all,fsize,0,1);
    imgOut2 = imageRestoration(imgOut,mask_all,fsize,1,10);
    imgOutN = imageRestoration(imgOut2,mask_all,fsize,1,n-10);
    %imgOut_comp(:,:,:,j) = imgOutN;
    
    figure('name',['Filtered image using ', num2str(fsize),' dimensional filter']);
    subplot(131);imshow(imgOut);
    title('Filtered image 1 times');
    subplot(132);imshow(imgOut2);
    title('Filtered image 10 times');
    subplot(133);imshow(imgOutN);
    title(['Filtered image ', num2str(n) ,' times']);
    j = j+1;
end
%}
%{
figure();
subplot(231); imshow(imgOut_comp(:,:,:,1)); title('5x5 filter');
subplot(232); imshow(imgOut_comp(:,:,:,2)); title('9x9 filter');
subplot(233); imshow(imgOut_comp(:,:,:,3)); title('13x13 filter');
subplot(234); imshow(imgOut_comp(:,:,:,4)); title('17x17 filter');
subplot(235); imshow(imgOut_comp(:,:,:,5)); title('21x21 filter');
subplot(236); imshow(imgOut_comp(:,:,:,6)); title('25x25 filter');
%}

% dynamic size filter
figure('name',['Filtered image using dynamic dimensional filter']);
j = 10;
k = j+1;
for i = 1:j
    fsize = (k-i)*2+1;
    
    if i == 1
        imgOut = imageRestoration(imgMasked_inv,mask_all,fsize,0,1);
    else
        imgOut = imageRestoration(imgOut,mask_all,fsize,1,1);
    end
    
    if i == 1
        subplot(131);imshow(imgOut);
        title(['Filtered image ', num2str(i) ,' times']);
    elseif i==floor(j/2)
        subplot(132);imshow(imgOut);
        title(['Filtered image ', num2str(i) ,' times']);
    elseif i==j
        subplot(133);imshow(imgOut);
        title(['Filtered image ', num2str(i) ,' times']);
    end
end