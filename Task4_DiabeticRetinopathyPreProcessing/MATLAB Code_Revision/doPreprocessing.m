% Data Pre-processing
% By: Susaf N.A; Hudalizaman
% Computer Vision Class
% March 2020 MTI UGM

function doPreprocessing(INLIST,STARTREAD,MAXREAD,OUTRES)
%doPreprocessing function: converting all resource image in one standard
%  -Usage-
%	doPreprocessing(INLIST,STARTREAD, MAXREAD, OUTRES)
%
%  -Inputs-
%    INLIST: input list
%	 STARTREAD: start index
%    MAXREAD: end index
%    OUTRES: output image size (square)
%    
%  -Outputs-
%    -
%
%  -Brief-
%   This funtion will do a grayscale normalization to the image,
%   image will be centered and cropped as a square image
%   image output will be resized as desired resolution
%
%Author: Susaf Noor Azhar, University of Gadjah Mada

%% CONSTANT
FEXT = '.PNG';
TESTMODE = 0; %0 disable, 1 enable

%% MAIN LOOP
for i=STARTREAD:MAXREAD
    
    %Read Image File
    T = INLIST(i,1);%read image list
    filename = strcat(T{1},FEXT);% combine string
    imgOri = imread(filename);% read image
    
    % print current progress
    fprintf('processing image %d of %d, IMG: %s \n',i,MAXREAD,filename)
        
%% COLOR NORMALIZATION
% ====================================   
if  TESTMODE==1 % === TEST ONLY!!! === 
    
    %
    % === METHOD1: use image complement to increase color contrast ===
    % === status : UNUSED, unstable output result ===
    mv = mean(mean(mean(imgOri)));
    
    if mv<80 % dark color
        % calculate color complement contrast
        imgOriInv = imcomplement(imgOri);
        imgOriHaze = imreducehaze(imgOriInv);
        imgOriContrast = imcomplement(imgOriHaze);
        % convert to grayscale
        Bgray = rgb2gray(imgOriContrast);    
        bwMask = Bgray(:,:,1)>30; % create mask
        se1 = strel('disk', 10); % create the filter
        bwMask = imopen(bwMask,se1); % morphology
    else
        bwMask = im2bw(imgOri,0.1); % binary mask
        se1 = strel('disk', 10);
        bwMask = imfill(bwMask,'holes');
        bwMask = imopen(bwMask,se1);
        imgOriContrast = imgOri;
    end
    
    imgCC = createNormalizedImage(imgOriContrast,bwMask);
    imgNewRes1 = createResizedImage(imgCC,OUTRES);
    %
    
    %
    % === METHOD2: use adaptive histeq to increase color contrast ===
    % === status : UNUSED, to many output noise ===
        
    RGB = imgOri;
    LAB = rgb2lab(RGB);
    L = LAB(:,:,1)/100;
    L = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005);
    LAB(:,:,1) = L*100;
    imgCN = lab2rgb(LAB);
    
    imgNewRes2 = createResizedImage(imgCN,OUTRES);   
    [~, ~, Ch] = size(imgNewRes2);    
    if Ch==3
        imgNewRes2 = rgb2gray(imgNewRes2);
    end       
   
end % end of TESTMODE==1
% ====================================   

    % === METHOD3: Red-Red-Green Transformation ===
    % === status : testing, have better gray contrast than previous 2 methods ===
    
    rc = imgOri(:,:,1);% red channel
    rg = imgOri(:,:,2);% green channel
    nr = imadjust(rc);% adjust contrast
    ng = imadjust(rg);% adjust contrast
    imgRGG = cat(3, nr, ng, ng); %combine RGG channel
    grayRGG = rgb2gray(imgRGG); %convert to gray
    agRGG = adapthisteq(grayRGG);
    gagRGG = imgaussfilt(agRGG,2);
    
    %% Image Centering and Resizing
    imgNewRes3 = createResizedImage(gagRGG,OUTRES);
    
    % check brightness result
    bwMask = imgNewRes3>20; % create mask
    bwMask = imfill(bwMask,'holes'); % fill image
    se1 = strel('disk',10); % disk filter
    bwMask = imopen(bwMask,se1); % morphological op
        
    % check brightness
    summask = sum(sum(bwMask)); 
    mv = sum(sum(imgNewRes3))/summask;
   
    if mv<190 %increase brightness
        dif = 190-mv;
        admsk = bwMask*dif;
        A = imgNewRes3;%imgaussfilt(imgNewRes,0.7);
        A = uint8(admsk)+A;
        imgNewRes3 = imadjust(A);
    end      
%% WRITING OUTPUT
    imwrite(imgNewRes3, filename,'WriteMode','append');    
%% PLOT
% ====================================   
if  TESTMODE==1 % === TEST ONLY!!! === 
    figure('WindowState', 'maximized');
    subplot(2,2,1); imshow(imgOri); title('Original Image');
    subplot(2,2,2); imshow(imgNewRes1); title('PREP2-CHN Method');
    subplot(2,2,3); imshow(imgNewRes2); title('PREP3-LAB CLAHE Method');
    subplot(2,2,4); imshow(imgNewRes3); title('PREP4-RGG CLAHE Method');
    
    figure('WindowState', 'maximized');
    subplot(2,2,1); imshow(imgOri); title('Original Image');
    subplot(2,2,2); imshow(imgRGG); title('RGG Image');
    subplot(2,2,3); imshow(grayRGG); title('gray RGG Image');
    subplot(2,2,4); imshow(imgNewRes3); title('Resized Gray RGG Image');
end % end of TESTMODE==1
% ====================================
end % end of for i=STARTREAD:MAXREAD
end % end of function