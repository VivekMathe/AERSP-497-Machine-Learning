close all;
clear all;
clc;

% creating a test track
x=[-1:0.01:-0.01,...
    cos(pi/2:-0.01:-pi/2),...
    -0.01:-0.01:-0.99,...
    -1*ones(size([-1:0.01:0.99]))];
y=[1*ones(size([-1:0.01:-0.01])),...
    sin(pi/2:-0.01:-pi/2),...
   -1*ones(size([-0.01:-0.01:-0.99])),...
    [-1:0.01:0.99]];


% x=[1*cos(0:0.01:2*pi)];
% y=[0.5*sin(0:0.01:2*pi)];


figure; hold on;
plot(x,y,'k--');
axis equal;

xc=mean(x);
yc=mean(y);
plot(xc,yc,'o','markerfacecolor',[0 0 0])
[tht,r]=cart2pol(x-xc,y-yc);
r_out=r.*1.10;
r_in=r.*0.90;
x_out=r_out.*cos(tht)+xc;
y_out=r_out.*sin(tht)+yc;
x_in =r_in.*cos(tht)+xc;
y_in =r_in.*sin(tht)+yc;
plot(x_in,y_in,'r');
plot(x_out,y_out,'b');

dr=abs(r_out-r_in);
rmax=max(abs(r_out-r_in));
rmin=min(abs(r_out-r_in));

load NN.mat;

%pick a starting point
[x0, y0]=ginput(1);

for iter=1:100
    [x1,y1,id]=closePT(x,y,x0,y0);
    if(id==length(x))
        road_vec=[x(1)-x(id);y(1)-y(id)];
    else
        road_vec=[x(id+1)-x(id);y(id+1)-y(id)];
    end   
    road_vec=road_vec/norm(road_vec);
    disc_vec=[x0-x1;y0-y1];
    car_dir=net([road_vec;disc_vec]);
    vel=rmin/2;
    x0_old=x0; y0_old=y0;
    x0=x0+vel*car_dir(1);
    y0=y0+vel*car_dir(2);
    plot([x0_old x0],[y0_old,y0],'k-');
    axis([min(x)-rmax max(x)+rmax min(y)-rmax max(y)+rmax]);
    pause(0.1);
end

