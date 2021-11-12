%FailSurf test
%clear all
clc
test =1; %Change number to calculate desired surface
if (test==1)
    %G. Mazzei Master, Plots using Max Stress criterion
    Xt=40.29;    Xc=43.91;    Yt=31.13;    Yc=57.96;    S=23.35;
    S45p=20.80;    S45n=38.17;    mu1112=-0.0052;    mu2212=-0.2;
    lambda=0;
    x=-80:0.5:80;
    y=-80:0.5:80;
    z=-80:0.5:80;
    [s1,s2,t12]=meshgrid(x,y,z);
    [F_11,F_1111,F_22,F_2222,F_12,F_1212,F_1122,F_1112,F_2212]=FailSurf.tens(Xt,Xc,Yt,Yc,S,S45p,S45n,mu1112,mu2212,lambda);
    f=FailSurf.criteria(s1,s2,t12,F_11,F_1111,F_22,F_2222,F_12,F_1212,F_1122,F_1112,F_2212);
    %g=FailSurf.graph(s1,s2,t12,f,2);
    %     hold on
    %     box on
    %     grid on
    %     axis tight
    %     daspect([1,1,1]); %data aspect ratio of 1:1
    X=0:1:90;
    T=X*pi/180;
    c=cos(T);
    s=sin(T);
    S_1x=Xt./c.^2;
    S_2x=Yt./s.^2;
    S_12x=S./(s.*c);
    Sx=(-1.*sqrt((F_1111-2.*F_1122-1.*F_1212+F_2222).*(c.^4)+(2.*F_1112-2.*F_2212).*s.*c.^3+(2.*F_1122+F_1212-2.*F_2222).*c.^2+2.*F_2212.*c.*s+F_2222)+(F_11-1.*F_22).*c.^2+F_12.*c.*s+F_22)./((F_11.^2-2.*F_11.*F_22-1.*F_12.^2+F_22.^2-1.*F_1111+2.*F_1122+F_1212-1.*F_2222).*c.^4+(2.*F_11.*F_12-2.*F_12.*F_22-2.*F_1112+2.*F_2212).*s.*c.^3+(2.*F_11.*F_22+F_12.^2-2.*F_22.^2-2.*F_1122-1.*F_1212+2.*F_2222).*c.^2+(2.*F_12.*F_22-2.*F_2212).*s.*c+F_22.^2-1.*F_2222);
    plot(X,S_1x,'-.k');
    axis ([0 90 30 60])
    grid on
    box on
    hold on
    plot(X,S_2x,'--k');
    plot(X,S_12x,':k');
    plot(X,Sx,'-r','LineWidth',2)
    xlabel('\theta [deg]','fontsize',16)  % x-axis label
    ylabel('\sigma_{xx} [MPa]','fontsize',16)  % y-axis label
    set(gca,'FontSize',14) %Sets the font size for axes
    set(gca,'FontName','Arial') %Sets the font size for axes
    plot([0 30 45 60 75 90], [41.03 36.21 36.07 35.72 34.39 34.39], 'ro')
    %plot(15,35.57,'rx')
    legend({'M1-1','M2-2','M1-2','OOC','Data'})
elseif (test==2)
    %Solving for sx as a function of theta
    %Define tensorial components to avoid runnin calc. twice
    tic
    F_11=0.001023099495182;
    F_1111=0.000566295072456799;
    F_1112=-3.427843350651909e-05;
    F_1122=-1.017023854135421e-04;
    F_12=0;
    F_1212=0.001834113595826;
    F_22=0.007435037777640;
    F_2212=4.840568372012957e-05;
    F_2222=6.095129420020747e-04;
    T=0:1:90;
    theta=(pi/180).*T;
    s=sin(theta);
    c=cos(theta);
    Sx=(-1.*sqrt((F_1111-2.*F_1122-1.*F_1212+F_2222).*(c.^4)+...
    (2.*F_1112-2.*F_2212).*s.*c.^3+(2.*F_1122+F_1212-2.*F_2222).*c.^2+2.*F_2212.*c.*s+F_2222)+...
    (F_11-1.*F_22).*c.^2+F_12.*c.*s+F_22)./((F_11.^2-2.*F_11.*F_22-1.*F_12.^2+F_22.^2-1.*F_1111+2.*F_1122+F_1212-1.*F_2222).*c.^4+...
    (2.*F_11.*F_12-2.*F_12.*F_22-2.*F_1112+2.*F_2212).*s.*c.^3+(2.*F_11.*F_22+F_12.^2-2.*F_22.^2-2.*F_1122-1.*F_1212+2.*F_2222).*c.^2+...
    (2.*F_12.*F_22-2.*F_2212).*s.*c+F_22.^2-1.*F_2222);
end