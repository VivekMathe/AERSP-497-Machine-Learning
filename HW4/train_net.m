clear all;
close all;
clc;

load data.mat;

net=feedforwardnet([6]);
net=configure(net, input, output);
net.divideparam.trainRatio= 100/100;
net.divideparam.valRatio  = 0/100;
net.divideparam.testRatio = 0/100;
net.trainParam.epochs     = 40000;

net=train(net,input,output);

save NN.mat net
