close all; clear all; clc;

%create a lane.
x=[1*cos(0:0.01:2*pi)];
y=[0.5*sin(0:0.01:2*pi)];

figure('position',[50 50 400 300],'color',[1 1 1]); 
hold on; axis equal;
title('track, please drive counter clockwise');
plot(x,y,'k--'); axis equal;

%second define the width of the track
xc=mean(x); yc=mean(y);
%plot(xc,yc,'o','markersize',10,'markerfacecolor',[0 0 0]);
[tht,r]=cart2pol(x-xc,y-yc);
r_out=r.*1.1; r_in=r.*0.9;
x_out=r_out.*cos(tht)+xc; y_out=r_out.*sin(tht)+yc;
x_in =r_in.*cos(tht)+xc; y_in =r_in.*sin(tht)+yc;
plot(x_in,y_in,'r');   % inner track
plot(x_out,y_out,'b'); % outer track

%width of the track
dr=abs(r_out-r_in);
rmax=max(abs(r_out-r_in));% maximum width
rmin=min(abs(r_out-r_in));% minimum width

input=[];
output=[];
for trail=1:60
    axis([min(x)-rmax max(x)+rmax min(y)-rmax max(y)+rmax])
    id=round(rand()*(length(x)-1))+1;
    x1=x(id)+(rand()-0.5)*rmax/2; y1=y(id)+(rand()-0.5)*rmax/2;
    [x0,y0,id]=closePT(x,y,x1,y1);  
    plot(x1,y1,'ok','markersize',5,'markerfacecolor',[0 0 0]);
    axis([x1-rmax*2 x1+rmax*2 y1-rmax*2 y1+rmax*2]);
    %get where the road is going
    if(id+1>length(x))
        road_vec=[x(1)-x(id);y(1)-y(id)];
    else
        road_vec=[x(id+1)-x(id);y(id+1)-y(id)];
    end
    road_vec=road_vec/norm(road_vec);
    dist_vec=[x1-x0;y1-y0];
    vel=rmax/3;
    h1=plot([x0,x0+road_vec(1)*0.2],[y0, y0+road_vec(2)*0.2],'k-');
    h2=plot(x1+cos([0:0.01:2*pi])*vel,y1+sin([0:0.01:2*pi])*vel,'k-');
    input=[input,[road_vec;dist_vec]];
    %tell the vehicle where to go, manual, slow
    [x2, y2]=ginput(1);
    car_dir=[x2-x1;y2-y1];
    car_dir=car_dir/norm(car_dir);
    %plot([x1,x1+car_dir(1)*0.2],[y1, y1+car_dir(2)*0.2],'k-');
    %plot(x2,y2,'o','markersize',5,'markerfacecolor',[0 0 0]);
    %car_dir=road_vec;
    output=[output,car_dir];
    delete(h1);
    delete(h2);
    pause(0.01);
end
axis([min(x)-rmax max(x)+rmax min(y)-rmax max(y)+rmax])
save data.mat input output

