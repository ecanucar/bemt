clear all
clc
close all
addpath xfoil
warning off
tic

% meter, second, kg, rad.
%%
%   GENERAL INPUTS
%   flight conditions
FlightSpeed = 49.17;                                % [m/s] %49.17 %60

%   shaft specs
ShaftRPM = 2400;                                    % [RPM] %2400
ShaftPowerHP = 70;                                  % [HP]
ShaftPower = 745.699872*ShaftPowerHP;               % [W]

%   geometry inputs
NumberOfStation = 21;                               % [m]
NumberOfBlades = 2; % 2
Dspinner = 0.3048;       %0.3048
LSpinner = 0.3048; %0.3048; %Spinner*2.5;           % [m]
DiaOptimizer = 0;
DesignDia = 1.7526;
DCLi = 0.7;
Dshank = 0.1;                                       % [m]
ZeroStation2one = 0.05;                             % [m]
AirfoilFilename = 'naca4415.txt';

%   fixed variables (do not change unless necessary)
MaxTipMachNumber = 0.72;                            % [-] 0.6637
Altitude = 0;
ncrit = 9;
XfoilIter = 300;
ShowBladeGeometry = 1;
XStationOffset = .5;
YStationOffset = 0;

run("loop.m");
run("print_results");