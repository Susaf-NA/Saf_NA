function [xc,yc,R,a] = computeCircleFit(x,y)
%computeCircleFit function: Fits a circle in x,y plane
% Result is center point (yc,xc) and radius R.  A is an optional
% output describing the circle's equation:
%
%   x^2+y^2+a(1)*x+a(2)*y+a(3)=0
%  -Usage-
%	createImageMask(iIn, mode)
%
%  -Inputs-
%	 iIn: input image
%    mode: mask mode (none, 'c' = circle)
%    
%  -Outputs-
%    bwMask: binary mask output
%
%Author: Bucher izhak 25/oct/1991
%%
    n = length(x);  

    xx = x.*x; 
    yy = y.*y; 
    xy = x.*y;

    A = [sum(x) sum(y) n; sum(xy) sum(yy) sum(y); sum(xx) sum(xy) sum(x)];
    B = [-sum(xx+yy); -sum(xx.*y+yy.*y); -sum(xx.*x+xy.*y)];

    a = A\B;

    xc = -.5*a(1);
    yc = -.5*a(2);
    R  = sqrt((a(1)^2+a(2)^2)/4-a(3));
end