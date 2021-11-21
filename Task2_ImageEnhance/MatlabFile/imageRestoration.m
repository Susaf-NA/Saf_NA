% Image Enhancement
% By: Susaf N.A
% Computer Vision Class
% February 2020 MTI UGM

function [out_img] = imageRestoration(in_img,mask,fsize,type,n)
%imageRestoration function: generating restored image using median filter
%  -Usage-
%	[out_img]: imageRestoration(in_img,mask,fsize,type,n)
%
%  -Inputs-
%	 in_img: original masked image (double RGB channel)
%    mask: masked area/region of interest (binary)
%    fsize: size of median filter (odd)
%    n: number of filter loop (int>0)
%  -Outputs-
%    out_Wiener: 
%Author: Susaf Noor Azhar, University of Gadjah Mada

% error check
if n<1
    n = 1;
end
if ~mod(fsize,2)
    fsize = fsize+1;
end

% separating RGB channel
RC = in_img(:, :, 1);
GC = in_img(:, :, 2);
BC = in_img(:, :, 3);

% creating median filter
mid = (fsize+1)/2;
mf = ones(fsize,fsize);

if type == 0
    mf(mid,mid) = 0; %zero at center value
    mf = mf/(fsize*fsize-1);
else
    mf(mid,mid) = type; %any value
    mf = mf/(fsize*fsize-1+type); %one at center value    
end

% filtering loop
for i=1:n
    % filtering image at Region of Interest (ROI) using roifit
    RC = roifilt2(mf, RC, mask);
    GC = roifilt2(mf, GC, mask);
    BC = roifilt2(mf, BC, mask);
end

% output
out_img = cat(3, RC, GC, BC);

end