% Alexander Vasilakis
% Aircraft Performance
% Assignment 2: Non Powered Glide

close all
clear all
clc

% Plane Constants
Area = 121; %sqft
MTOW = 1800; %lbs
% Usable Fuel 
FuelW = 244.8; %lbs Usable Fuel
EmptyW = 1168.45; %lbs
CargoW = 99.208; %lbs
PassengerW = 287; %lbs to get to about MTOW
PayloadW = CargoW + PassengerW;

addpath('C:\Users\axvas\OneDrive\Desktop\SeniorAeroMatlab\AircraftPerformance');

% % FLIGHT MANUAL DATA
% Best Glide: 85 KIAS
% Best Angle of Climb: 70 KIAS
% BEst Rate of Climb: 85 KIAS

% CD function
Cdfunc = @(CL) 0.024292 + 1.6647e-9*CL + 0.071696*CL^2;

% Predefine Variables to be tracked
Time_historyG = [];
Drag_historyG = [];
CL_historyG = [];
CD_historyG = [];
AltitudehistoryG = [];
ROD_historyG = [];
GlideAngle_historyG = [];

% Specify An Airspeed
VairKTS = 70; %KTIS
Vairft_s = VairKTS * 1.68781; %ft/s

% Loop Parameters
dt = 10; % Change in time Seconds
height = 10000; % ft
altitude = height*0.3048; % convert to m for ISA calculator

time = 0;

while altitude > 0

Weight = EmptyW + FuelW + PayloadW;
[T,~,~,rho,~,~] = atmosisa(altitude);
Density = rho/515.379; % Get Density in slugs/ft^3
TempF = 1.8 * (T-273) + 32;

CL = Weight/(.5*Density*Vairft_s^2*Area);
CD = Cdfunc(CL);
DragF = .5*Density*Vairft_s^2*Area*CD;
ROD = (DragF*Vairft_s)/Weight;
RODms = ROD/3.281;
GlideAngle = asind(DragF/Weight);

altitude = altitude - RODms*dt;
Drag_historyG(:,end+1) = DragF;
CL_historyG(:,end+1) = CL;
CD_historyG(:,end+1) = CD;
AltitudehistoryG(:,end+1) = altitude;
ROD_historyG(:,end+1) = ROD;
GlideAngle_historyG(:,end+1) = GlideAngle;
Time_historyG(:,end+1) = time;

time = time + dt;

end

%% Plotting
% Convert time to minutes
Time_minutes = Time_historyG/60;
Altitude_ft = AltitudehistoryG / 0.3048;

% Glide angle vs time
figure;
plot(Time_minutes,GlideAngle_historyG,'LineWidth',1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Flight Path Angle (degrees)');
title('Glide Angle vs Time');

% Rate of descent vs time
figure;
plot(Time_minutes,ROD_historyG*60,'LineWidth',1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Rate of Descent (ft/min)');
title('Rate of Descent vs Time');

% Altitude vs time
figure;
plot(Time_minutes,Altitude_ft,'LineWidth',1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Altitude (ft)');
title('Glide Altitude vs Time');

% Glide ratio vs time
GlideRatio = 1./tand(abs(GlideAngle_historyG));

figure;
plot(Time_minutes,GlideRatio,'LineWidth',1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Glide Ratio (L/D)');
title('Glide Ratio vs Time');