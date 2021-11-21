function IOUT = createResizedImage(IIN, OUTRES)
%createResizedImage function: converting all resource image in one standard
%  -Usage-
%	createResizedImage(IIN, OUTRES)
%
%  -Inputs-
%	 IIN: image input
%    OUTRES: new resoultion
%    
%  -Outputs-
%    IOUT: image output
%
%  -Brief-
%   This funtion will create a square canvas for temporary canvas,
%   image will be cropped using a circle mask
%   the circle mask is calculated from the image
%Author: Susaf Noor Azhar, University of Gadjah Mada
    %%
    % get the image dimension
    [R, C, Ch] = size(IIN);% Rows(Y),Columns(Y),Color Channel
    %% CANVAS UPSCALING
    % check the canvas dimension needed
    if R == C % same as image
        iCanvas = IIN;
        Csize = C;
        sY = 1; % start Y(0)
        sX = 1; % start X(0)
    else %build a bigger canvas
        if R<C % (Y<X)horizontal
            Csize = C; % canvas size
            d = (C-R)/2; % displacement
            sY = 1+d; % Y(0) cordinates moved
            sX = 1; % X(0) stay at 1
        else % (Y>X)vertical
            Csize = R;
            d = (R-C)/2;
            sY = 1; % Y(0) stay at 1
            sX = 1+d; % X(0) cordinates moved
        end

        % convert to integer, prevent error
        sY = int32(sY);
        sX = int32(sX);

        temp = zeros(Csize,Csize,Ch); % zero matrix
        temp(sY:(sY+R-1),sX:(sX+C-1),:) = IIN; % copy the image to the new coordinate

        if isa(IIN,'integer')
            iCanvas = uint8(temp); %convert to integer
        else
            iCanvas = temp; %as input
        end
    end

    clear temp;% release some memory

    % check data type
    if isfloat(iCanvas)
        iCanvas = uint8(iCanvas.*255); % convert to integer
    end

    % check RGB type
    if Ch==3 % RGB
        gray_canvas = rgb2gray(iCanvas); % temporary variable
    else % Grayscale /BW
        gray_canvas = iCanvas; % temporary variable
    end

    %% CREATE MASK
    % check brightness
    mv = mean(mean(gray_canvas));

    if mv<65 % low brightness
        A = gray_canvas+50;
        mask1 = imadjust(A);
        bwmask1 = mask1>30; %rgb
    else % high brightness
        % convert to binary mask
        bwmask1 = im2bw(gray_canvas,0.1);%binary
    end

    % mask morphology
    se1 = strel('disk', 10);
    bwmask1 = imfill(bwmask1,'holes');
    bwmask = imopen(bwmask1,se1);
    % Circle estimation
    %estimate the radius
    perim = bwperim(bwmask);
    [yi, xi] = find(perim);
    badIndexes = (yi == sY) | (xi == sX) | (yi == (sY+R-1))| (xi == (sX+C-1));
    xi(badIndexes) = []; % Remove the border locations.
    yi(badIndexes) = []; % Remove the border locations.

    [X,Y,R,~] = computeCircleFit(xi,yi); %[xc,yc,R,a]

    [nC, nR] = meshgrid(1:Csize, 1:Csize); % rows = y; columns = x
    bwmask = (nR - Y).^2 + (nC - X).^2 <= R.^2;

    if Ch==3 % RGB
        iCanvas= lin2rgb(iCanvas); % increase contrast        
    else
        iCanvas= imadjust(iCanvas); % increase contrast
    end
    iCanvas = im2double(iCanvas);
    iCanvas = iCanvas.*bwmask;

    %% CROP AND RESIZE IMAGE
    R = floor(R);
    D = R*2;
    midRows = Csize/2; %y
    midColumns = min(xi); %x
    r = [midColumns (midRows-R) D D];
    imgNewCrop = imcrop(iCanvas,r);
    imgNewCrop = uint8(imgNewCrop*255);

    IOUT = imresize(imgNewCrop,[OUTRES OUTRES],'Antialiasing',false);

end % end of function