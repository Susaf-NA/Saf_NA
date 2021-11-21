function OList = doImageAugmentation(DList, iMIN, iMAX, pfix)
%doPreprocessing function: increase number of data using data augmentation
%  -Usage-
%	doImageAugmentation(DList, iMIN, iMAX, pfix)
%
%  -Inputs-
%    DList: input list
%	 iMIN: start index
%    iMAX: end index
%    pfix:
    
%  -Outputs-
%    OList: output list
%
%  -Brief-
%   This funtion will generate random augmented data,
%   augmentation : rotation, flip Horizontal, flip Vertical or both
%
%Author: Susaf Noor Azhar, University of Gadjah Mada
%%
for i=(iMIN+1):iMAX
    FEXT = '.PNG';
    mode = randi(4);
    idx = randi(iMIN);
    OList = DList;

    L = DList(idx,1); %read image list
    filename = strcat(L{1},FEXT);
    fprintf('duplicate image %d of %d, IMG: %s \n',i,iMAX,filename)

    I = imread(filename);   

    % select augmentation mode
    if mode ==1 %rotate
        deg=randi(345);
        T = imrotate(I,deg,'bilinear','crop');
    elseif mode==2 %flip H
        T = flip(I,2);
    elseif mode==3 %flip V
        T = flip(I,1);
    else %flip H+V
        T = flip(I,2);
        T = flip(T,1);
    end

    % if number below 4 digit
    if floor(i/1000)<1
        pfix2 = strcat(pfix,'0');
    else
        pfix2 = pfix;
    end

    % generate name
    nfn = strcat(pfix2,num2str(i));
    OList(i,:) = {nfn,DList{idx,2}};
    filename = strcat(nfn,FEXT);
    
    % write output
    imwrite(T,filename,'WriteMode','append');
end % end of i=(iMIN+1):iMAX

end % end of function