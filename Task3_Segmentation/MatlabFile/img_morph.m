% Image Morphologycal Operation
% By: Susaf N.A
% Computer Vision Class
% March 2020 MTI UGM

function [out_img] = img_morph(imgBW, morph_sequence, morp_val)
%imageRestoration function: generating restored image using median filter
%  -Usage-
%	[out_img]: imageMorphology(imgBW, morph_sequence,morp_valn)
%
%  -Inputs-
%	 imgBW: original binary image
%    morph_sequence: morphology methods sequence (1:erode, 2:dilate, 3:Open, 4:Close,
%    5: Erode-S)
%    morp_val: filter size
%    
%  -Outputs-
%    out_img: processed image
%Author: Susaf Noor Azhar, University of Gadjah Mada

[C, R] = size(morph_sequence); %calculate the task size

spC = 2; %subplot column
spR = R; %subplot row

imgProc = imgBW;
figure();

for i=1:R
   
    ms = morph_sequence(i); %assign the task
    mv = morp_val(i); %asign the value
    se1 = strel('disk', mv); %create the filter
    imgprev = imgProc; %previous image
    
    if ms == 1 %erode
        imgProc = imerode(imgProc,se1);
        t = ['erode ', num2str(mv), 'x', num2str(mv)];
    elseif ms == 2 %dilate
        imgProc = imdilate(imgProc,se1);
        t = ['dilate ', num2str(mv), 'x', num2str(mv)];
    elseif ms == 3 %open
        imgProc = imopen(imgProc,se1);
        t = ['open ', num2str(mv), 'x', num2str(mv)];
    elseif ms == 4 %close
        imgProc = imclose(imgProc,se1);
        t = ['close ', num2str(mv), 'x', num2str(mv)];
    elseif ms == 5 %erode Special
        % erode by val
        se1 = strel('disk', mv);
        P1 = imerode(imgProc,se1);
        P1_diff = imgProc~= P1;
        
        % erode the difference by 1x1
        se1 = strel('disk', 1);
        P2 = imerode(P1_diff,se1);
        % dilate the P1 by 1x1
        P3 = imdilate(P1,se1);
        imgProc = P2 | P3;
        
        t = ['Erode-S ', num2str(mv), 'x', num2str(mv)];
    end
    
    imgDiff = imgprev ~= imgProc; %difference with previous image
    
    subplot(spC,spR,i);imshow(imgProc);title(t);
    subplot(spC,spR,i+R);imshow(imgDiff);title('diff');
end
out_img = imgProc;
end