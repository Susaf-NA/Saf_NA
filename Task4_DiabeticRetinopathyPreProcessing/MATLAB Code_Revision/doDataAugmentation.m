function doDataAugmentation(TLIST, MAXLIST)
%doPreprocessing function: increase number of data using data augmentation
%  -Usage-
%	doDataAugmentation(TLIST, MAXLIST)
%
%  -Inputs-
%    TLIST: input list
%	 MAXLIST: start index
%    
%  -Outputs-
%    -
%
%  -Brief-
%   This funtion will check the data distribution,
%   data will be augmented to match the number of biggest population 
%
%Author: Susaf Noor Azhar, University of Gadjah Mada
%% INIT   
    nt0 = 0;
    nt1 = 0;
    nt2 = 0;
    nt3 = 0;
    nt4 = 0;

    temp0 = cell(MAXLIST,2);
    temp1 = cell(MAXLIST,2);
    temp2 = cell(MAXLIST,2);
    temp3 = cell(MAXLIST,2);
    temp4 = cell(MAXLIST,2);

%% DATA DISTIRBUTION
    for i=1:MAXLIST
        V = TLIST{i,2};
        if V==0
            nt0 = nt0+1;
            temp0(nt0,:) = TLIST(i,:);
        elseif V==1
            nt1 = nt1+1;
            temp1(nt1,:) = TLIST(i,:);
        elseif V==2
            nt2 = nt2+1;
            temp2(nt2,:) = TLIST(i,:);
        elseif V==3
            nt3 = nt3+1;
            temp3(nt3,:) = TLIST(i,:);
        elseif V==4
            nt4 = nt4+1;
            temp4(nt4,:) = TLIST(i,:);
        end
    end

    typeNum = [nt0 nt1 nt2 nt3 nt4];
    maxN = max(typeNum);

    newList0 = cell(maxN,2);
    newList1 = cell(maxN,2);
    newList2 = cell(maxN,2);
    newList3 = cell(maxN,2);
    newList4 = cell(maxN,2);

    newList0(1:nt0,:) = temp0(1:nt0,:);
    newList1(1:nt1,:) = temp1(1:nt1,:);
    newList2(1:nt2,:) = temp2(1:nt2,:);
    newList3(1:nt3,:) = temp3(1:nt3,:);
    newList4(1:nt4,:) = temp4(1:nt4,:);

    clear temp0 temp1 temp2 temp3 temp4; %clear some memory

%% GENERATE RANDOM AUGMENTED DATA
    newList1 = doImageAugmentation(newList1,nt1,maxN,'adt1xxxx');
    newList2 = doImageAugmentation(newList2,nt2,maxN,'adt2xxxx');
    newList3 = doImageAugmentation(newList3,nt3,maxN,'adt3xxxx');
    newList4 = doImageAugmentation(newList4,nt4,maxN,'adt4xxxx');
end % end of function