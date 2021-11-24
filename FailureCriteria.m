%________________________________________________________________
%
%                 Evaluation of Failure Criteria Models
%
%________________________________________________________________
%   
% Define Strength Parameters
%

   Xt=41.073;
   Xc=41.073;
   Yt=25.172;
   Yc=25.172;
   S=32.6;
   S45=34.0;
   mu1=-0.04;
   mu2=-0.25;
   lambda=0.38;
%
% Set up a grid within the desired limits in MPa for S2 (x) and 
% T12 (y). Within this grid values of the failure criteria will 
% be calculated using values of S2 and T12 on a given S1 plane
%
   x=-70:0.5:70;
   y=-70:0.5:70;
   z=0:0.5:70;
   [S1,S2,T12]=meshgrid(x,y,z);


%
% Inquire the desired model from the user
%
   reply = input('Which model would you like to use? [Tsai, TsaiM, Gol or GolM]: ','s');
%
% Compute the appropriate model based on user's input, or "break" 
% if non-existing model
%
   if strcmp(reply,'Tsai')
     disp('Evaluating the Tsai-Wu Criteria')
     L1='Tsai-Wu Criteria';
     criteria=Tsai(Xt,Xc,Yt,Yc,S,S1,S2,T12);
   elseif strcmp(reply,'TsaiM')
     disp('Evaluating the Modified Tsai Criteria')
     L1='Modified Tsai Criteria';
     criteria=TsaiM(Xt,Xc,Yt,Yc,S,mu1,mu2,lambda,S1,S2,T12);
   elseif strcmp(reply,'Gol')
     disp('Evaluating the Gol-denblat Criteria')
     L1='Gol-denblat Criteria';
     criteria=Gol(Xt,Xc,Yt,Yc,S,S45,S1,S2,T12);
   elseif strcmp(reply,'GolM')
     disp('Evaluating the Modified Gol-denblat Criteria')
     L1='Modified Gol-denblat Criteria';
     criteria=GolM(Xt,Xc,Yt,Yc,S,S45,mu1,mu2,lambda,S1,S2,T12);
   else
     disp('Model not available')
     %break;
   end
%
% Plot the failure criteria at values of 1., 0.75, 0.5 and 0.25
% interpolating on the S1-S2 grid
%
   
cvals = linspace(0,1,5) 
Sx = [];
Sy = [];
Sz = -70:70;
figure(1)
%colormap(3)
contourslice(S1,S2,T12,criteria,Sx,Sy,Sz,cvals);
view(3);
axis([-70,70,-70,70,-70,70]);
daspect([1,1,1]);
box on
axis tight
  
   %contour(S2,T12,criteria,[1,1],'-k','showtext','off')

   set(gca,'FontSize',16)
   hold on
%   contour(S2,T12,criteria,[1,0.75],'--k','showtext','off')
   hold on
 %  contour(S2,T12,criteria,[1,0.5],'-.k','showtext','off')
   hold on
 %  contour(S2,T12,criteria,[1,0.25],'--k','showtext','off')
 %  hold on
 %  grid on
 %
 xlabel('\sigma_{11}','fontsize',20)  % x-axis label
 ylabel('\sigma_{22}','fontsize',20)  % y-axis label
 zlabel('\tau_{12}','fontsize',20)  % z-axis label

 %  colormap(gray)
   
 %  hold on
  % x1=[-70,50];
  % y1=[0,0];
  % plot(x1,y1,'k')
  % hold on
  % x2=[0,0];
  % y2=[-70,50];
  % plot(x2,y2,'k')
  % title (L1,'fontsize',20)   
   print('Figure(1)','-depsc')