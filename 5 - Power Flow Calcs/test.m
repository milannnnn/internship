clear all;
close all;
clc;

runpf('case9');

 
a = loadcase('case9');
[Ybus, Yf, Yt] = makeYbus(a);
