close all;
clear all;
clc;

dat=h5read('transition_bl2.h5','/Velocity_0001');
dat=squeeze(dat);
u=squeeze(dat(1,:,:));
w=abs(squeeze(dat(3,:,:)));

figure;
contourf(u',[-0.01:0.001:0.03],'linestyle','none');
figure;
contourf(w',[-0.01:0.001:0.03],'linestyle','none');

d=45;
K = (1/d^2)*ones(d);
u2 = conv2(u,K,'same');
w2 = conv2(w,K,'same');

figure;
contourf(u2(1:5:end,1:5:end)',[-0.01:0.001:0.03],'linestyle','none');
figure;
contourf(w2(1:5:end,1:5:end)',[-0.01:0.001:0.03],'linestyle','none');

