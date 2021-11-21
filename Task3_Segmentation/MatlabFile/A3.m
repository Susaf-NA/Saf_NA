% Image Segmentation
% By: Susaf N.A
% Computer Vision Class
% March 2020 MTI UGM

%% Inizialization and data acquisition
clc; %clearing command window
clear all; close all;  %clear all variable and close all window
fontSize = 24; %label font size

% load image name with the extention type
filename = 'Picture1.jpg';

% Read image
imgOri = imread(filename);
imgCrop1 = imread('crop1.png');
imgCrop2 = imread('crop2.png');
I = imgOri(:,:,1);

% Convert to double
dRGB_Ori = im2double(imgOri);
dRC_Ori = dRGB_Ori(:,:,1); %double Red Channel - Original value
dGC_Ori = dRGB_Ori(:,:,2); %double Green Channel - Original value
dBC_Ori = dRGB_Ori(:,:,3); %double Blue Channel - Original value

%% Histogram Analisis

[counts1,x1] = imhist(imgOri,16);
[counts2,x2] = imhist(imgCrop1,16);
[counts3,x3] = imhist(imgCrop2,16);

subplot(2,3,1);stem(x1,counts1,'LineWidth',4);title('Histogram of Whole Image', 'FontSize', fontSize);
subplot(2,3,2);stem(x2,counts2,'LineWidth',4);title('Histogram of Tablet Image', 'FontSize', fontSize);
subplot(2,3,3);stem(x3,counts3,'LineWidth',4);title('Histogram of Capsule Image', 'FontSize', fontSize);
subplot(2,3,4);imshow(imgOri);title('Whole Image', 'FontSize', fontSize);
subplot(2,3,5);imshow(imgCrop1);title('Tablet Image', 'FontSize', fontSize);
subplot(2,3,6);imshow(imgCrop2);title('Capsule Image', 'FontSize', fontSize);

%% PROCESS 1
% Binary Mask
Tlvl_1 = graythresh(imgOri); %otsu treshold = 0.477
BW = im2bw(imgOri, Tlvl_1);
BW_mask = BW(:,:,1)==1;

% Edge Detection
Edge_Canny = edge(I,'Canny'); %using Canny

% Merging mask
img_BE = BW_mask | Edge_Canny; %image with binary color and edge detection
% Filling holes
img_BEF = imfill(img_BE,'holes'); %fill the empty area

figure;
subplot(1,3,1);imshow(BW_mask);title('Binary Mask, Otsu Treshold', 'FontSize', fontSize);
subplot(1,3,2);imshow(img_BE);title('Binary Mask + Edge Canny',  'FontSize', fontSize);
subplot(1,3,3);imshow(img_BEF);title('Binary Mask + Edge Canny + Fill',  'FontSize', fontSize);

% Testing of "Erode-S" Method
%{
se1 = strel('disk', 5);
P1 = imerode(img_BEF,se1);
P1_diff = img_BEF~= P1;
se1 = strel('disk', 1);
P2 = imerode(P1_diff,se1);
P3 = imdilate(P1,se1);
img_merge = P2 | P3;

figure;
subplot(2,3,1);imshow(img_BEF);title('Mask',  'FontSize', fontSize);
subplot(2,3,2);imshow(P1);title('ME5: Mask -> erode 5x5',  'FontSize', fontSize);
subplot(2,3,3);imshow(P1_diff);title('ME5D: Mask - ME5',  'FontSize', fontSize);
subplot(2,3,4);imshow(P2);title('ME5DE1: ME5D -> erode 1x1',  'FontSize', fontSize);
subplot(2,3,5);imshow(img_merge);title('ME5 + ME5DE1',  'FontSize', fontSize);
%}

% morphological process
%1 = erode
%2 = dilate
%3 = open (ed)
%4 = close (de)
%5 = special
morph_sequence = [5 5 3 2];
morp_val = [5 3 4 8];

img_sgmnt = img_morph(img_BEF, morph_sequence, morp_val); %morphological function
inv_sgmnt = ~img_sgmnt;

% Apply mask to original image (dummy)
imgProc1 = imgOri;
A = (dRC_Ori .* img_sgmnt)>0;
An = A * 255;
B = (dRC_Ori .* inv_sgmnt) * 255;
imgProc1(:,:,1) = An + B;

figure;
subplot(1,2,1);imshow(imgOri);title('Original Image','FontSize', fontSize);
subplot(1,2,2);imshow(imgProc1);title('Segmented Area from Process-1','FontSize', fontSize);
%% PROCESS 2
% Apply previous mask to original image
imgRC_masked = dRC_Ori .* img_sgmnt;
imgGC_masked = dGC_Ori .* img_sgmnt;
imgBC_masked = dBC_Ori .* img_sgmnt;
imgMasked = cat(3, imgRC_masked, imgGC_masked, imgBC_masked);

Tlvl_2 = 0.37;%graythresh(imgOri);
BW_mask = im2bw(imgMasked, Tlvl_2);
img_OF = imfill(BW_mask,'holes');

figure;
subplot(1,2,1);imshow(BW_mask);title(['Binary Mask, Treshold=',num2str(Tlvl_2)],'FontSize', fontSize);
subplot(1,2,2);imshow(img_OF);title('Filled Mask','FontSize', fontSize);

morph_sequence = [1 1 2];
morp_val = [3 2 5];
img_sgmnt = img_morph(img_OF, morph_sequence, morp_val);
inv_sgmnt = ~img_sgmnt;

imgProc2 = imgOri; %overlay to original image
A = (dRC_Ori .* img_sgmnt)>0;
An = A * 255;
B = (dRC_Ori .* inv_sgmnt) * 255;
imgProc2(:,:,1) = An + B;

figure;
subplot(1,2,1);imshow(imgOri);title('Original Image','FontSize', fontSize);
subplot(1,2,2);imshow(imgProc2);title('Segmented Area from Process-2','FontSize', fontSize);

close all;
%% PROCESS 3
% Apply previous mask to original image
imgRC_masked = dRC_Ori .* img_sgmnt;
imgGC_masked = dGC_Ori .* img_sgmnt;
imgBC_masked = dBC_Ori .* img_sgmnt;
imgMasked = cat(3, imgRC_masked, imgGC_masked, imgBC_masked);

% Double Treshold
Tlvl_3 = 0.57;
% low value
imgRes1(:,:,1)=(imgMasked(:,:,1) > 0 & imgMasked(:,:,1) < Tlvl_3)*0.5;
imgRes1(:,:,2)=(imgMasked(:,:,2) > 0 & imgMasked(:,:,2) < Tlvl_3)*0.5;
imgRes1(:,:,3)=(imgMasked(:,:,3) > 0 & imgMasked(:,:,3) < Tlvl_3)*0.5;
% high value
imgRes2(:,:,1)=imgMasked(:,:,1) > Tlvl_3;
imgRes2(:,:,2)=imgMasked(:,:,2) > Tlvl_3;
imgRes2(:,:,3)=imgMasked(:,:,3) > Tlvl_3;

imgNew = im2double(imgRes1) + im2double(imgRes2);

figure;
imshow(imgNew);title('Binary Mask with 2 Treshold','FontSize', fontSize);

% only take the high value
img_OF = imgRes2(:,:,1);

% morphological process
%1 = erode
%2 = dilate
%3 = open (ed)
%4 = close (de)
%5 = special
morph_sequence = [3 2];
morp_val = [8 6];
img_sgmnt2 = img_morph(img_OF, morph_sequence, morp_val);
img_sgmnt3 = img_sgmnt2 & img_sgmnt;
inv_sgmnt3 = ~img_sgmnt3;

% Apply mask to original image (dummy)
imgProc3 = imgProc2; %overlay to previous result
A = (dBC_Ori .* img_sgmnt3)>0;
An = A * 255;
B = (dBC_Ori .* inv_sgmnt3) * 255;
imgProc3(:,:,2) = An + B;

figure;
subplot(1,2,1);imshow(imgOri);title('Original Image','FontSize', fontSize);
subplot(1,2,2);imshow(imgProc3);title('Segmented Area from Process-3','FontSize', fontSize);

close all;
%% Final Result

img_all = inv_sgmnt;
img_tablet = inv_sgmnt3;
img_capsule = ~(img_sgmnt - img_sgmnt3);

figure;
subplot(1,2,1);imshow(imgOri);title('Original Image','FontSize', fontSize);
subplot(1,2,2);imshow(imgProc3);title('Segmented Image','FontSize', fontSize);
figure;
subplot(1,3,1);imshow(img_all);title('All Object','FontSize', fontSize);
subplot(1,3,2);imshow(img_tablet);title('Tablet Only','FontSize', fontSize);
subplot(1,3,3);imshow(img_capsule);title('Capsule Only','FontSize', fontSize);