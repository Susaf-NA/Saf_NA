% Data Pre-processing
% By: Susaf N.A; Hudalizaman
% Computer Vision Class
% March 2020 MTI UGM
%
% Brief: Main function to preprocessing the image

%% INIT

% clear command window, all variable and close all window
clc; clear all; close all;

%load the list
trainList; %call list.m
[MaxList, C] = size(TList); % size of the list [rows, columns]
n = MaxList;

%% PROCESS
doPreprocessing(TList,1,n,256); % call pre processing
doDataAugmentation(TList,n); % call data augmentation