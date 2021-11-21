function outImg = createNormalizedImage(inImg, roiMask)
%createNormalizedImage function: create normalized image
%  -Usage-
%	createNormalizedImage(inImg, roiMask)
%
%  -Inputs-
%	 inImg: input image
%    roiMask: region of interest ('1' = ROI, '0' = ommited)
%    
%  -Outputs-
%    outImg: normalized image output
%
%Author: Susaf Noor Azhar, University of Gadjah Mada (March 2020)

    ommit_mask = ~roiMask; % create ommited mask
    ommit_sum = sum(ommit_mask,'All'); % number of ommited area
    
    [M,N,~] = size(inImg); % get size of input image
    d_img = double(inImg); % double needed for computations
    m_zeros = zeros(M*N,3);
    z = 1;
    
    mean_vec = sum(sum(d_img))/(M*N-ommit_sum); % a vector containing the mean r,g and b value
    v1 = [mean_vec(1),mean_vec(2),mean_vec(3)]; % means in red, green and blue

    for i=1:M
        for j=1:N
            if roiMask(i,j)==1
                v = [d_img(i,j,1),d_img(i,j,2),d_img(i,j,3)]; % image pixel at i,j
                m_zeros(z,:) = v - v1; % image normed to mean zero
            end
        z = z + 1;
        end
    end
    
    C = cov(m_zeros); % covariance computed using Matlab cov function

    %find eigenvalues and eigenvectors of C.
    [V,D] = eig(C); % computes the eigenvectors(V) and eigenvalues(diagonal elements of D) of the color cluster C
    
    %get the max. eigenvalue meig and the corresponding eigenvector ev0.
    max_eig = max(max(D)); % computes the maximum eigenvalue of C. Could also be norm(C)
    if(max_eig==D(1,1)), ev0=V(:,1); end
    if(max_eig==D(2,2)), ev0=V(:,2); end
    if(max_eig==D(3,3)), ev0=V(:,3); end
    % selects the eigenvector belonging to the greatest eigenvalue

    m_id = eye(3); % identity matrix of dimension 3
    wb_axis = [1;1;1]/sqrt(3); % unit vector pointing from origin along the main diagonal
    rot_vec = cross(ev0,wb_axis); % rotation axis , cross(A,B)=A×B
    cosphi = abs(dot(ev0,wb_axis)); % dot product, i.e. sum((ev0.*wbaxis))
    sinphi = norm(rot_vec); % sinphi is the length of the cross product of two unit vectors
    %normalized rotation axis.
    rot_vec = rot_vec/sinphi; % normalize nvec

    if(cosphi>1) 
        d_img = uint8(d_img);        
        outImg = d_img;
    else % we normalize
        n3 = rot_vec(3); n2 = rot_vec(2); n1 = rot_vec(1);   
        
        % unit vector along the rotation axis
        U = [[ 0  -n3  n2]; [ n3   0  -n1]; [ -n2 n1  0]];
        U2 = U*U;
        Rphi = m_id + (U*sinphi) + (U2*(1-cosphi));

        n0   = [0 0 0]';
        n255 = [255 255 255]';
        
        g = zeros(M,N,3);
        for i=1:M
            for j=1:N
                if roiMask(i,j) ==1
                    s(1) = d_img(i,j,1)-mean_vec(1); % compute vector s of normalized image at i,j
                    s(2) = d_img(i,j,2)-mean_vec(2);
                    s(3) = d_img(i,j,3)-mean_vec(3);
                    t = Rphi*s' ; % s transposed, as s is row vector, then rotated
                    tt = floor(t + [128 128 128]'); % shift to middle of cube and make it integer
                    tt = max(tt,n0); % handling underflow
                    tt = min(tt,n255); % handling overflow
                    g(i,j,:) = tt;
                end
            end
        end

        g = uint8(g);        
        outImg = g;
    end
end % end of function