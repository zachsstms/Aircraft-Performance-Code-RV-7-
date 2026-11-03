% Alexander Vasilakis
% Performance
% Assignment 2

close all
clear all
clc

% Assume Thrust is aligned with flight path
% Climb and Descent Solver: Constant Airspeed, MAP, 

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


% Specify An Airspeed
VairKTS = 70; %KTIS
Vairft_s = VairKTS * 1.68781; %ft/s


% Predefine Variables to be tracked
Time_historyC = [];
Fuel_historyC = [];
Weight_historyC = [];
Thrust_historyC = [];
Drag_historyC = [];
Power_historyC = [];
CL_historyC = [];
CD_historyC = [];
ClimbhistoryC = [];
Eta_historyC = [];
ROC_historyC = [];
ClimbAngle_historyC = [];

%predefine initial FuelW and Intial altitude
CurrentFuelW = FuelW; %lbs
t = 0;

% MAP and height can be changed to induce descent or climb
% Specify Manifold PRESSURE
MAP = 16;
% Loop Parameters
dt = 30; % Change in time Seconds
height = 10000; % ft
altitude = height*0.3048; % convert to m for ISA calculator

% START LOOP HERE
% Time Marching Loop
while CurrentFuelW > 0
TAS = VairKTS;
% Calculate Weight
Weight = EmptyW + PayloadW + CurrentFuelW;

% Obtain Atmospheric Principles
[T,~,~,rho,~,~] = atmosisa(altitude);

Density = rho/515.379; % Get Density in slugs/ft^3
TempF = 1.8 * (T-273) + 32;

[TDDifference,Thrust,Drag,FuelFlow,Power,CL,CD,RPM,FuelConsumption,Eta] = thrust_drag_difference(TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);

FlightPathAngle = asind(TDDifference/Weight);
ROC = (TDDifference*Vairft_s)/Weight;
ROCms = ROC/3.281;
ROC2 = Vairft_s*sind(FlightPathAngle);
% Fuel burned
FuelBurned = FuelFlow/3600 * dt;

altitude = altitude + ROCms*dt; % this is in meters, will convert at end to ft
  % Save results
    Time_historyC(:,end+1) = t;
    Fuel_historyC(:,end+1) = CurrentFuelW;
    Weight_historyC(:,end+1) = Weight;
    Thrust_historyC(:,end+1) = Thrust;
    Drag_historyC(:,end+1) = Drag;
    Power_historyC(:,end+1) = Power;
    CL_historyC(:,end+1) = CL;
    CD_historyC(:,end+1) = CD;
    ClimbhistoryC(:,end+1) = altitude;
    Eta_historyC(:,end+1) = Eta;
    ROC_historyC(:,end+1) = ROC;
    ClimbAngle_historyC(:,end+1) = FlightPathAngle;
    % Update fuel
    CurrentFuelW = CurrentFuelW - FuelBurned;

    if CurrentFuelW < 0
        CurrentFuelW = 0;
    end

    % Update time
    t = t + dt;
end

%% Plotting
%% PLOT FLIGHT PERFORMANCE

% Convert time to minutes
Time_minutes = Time_historyC / 60;

% Convert altitude from meters to feet
Altitude_ft = ClimbhistoryC / 0.3048;

% Convert ROC from ft/s to ft/min
ROC_fpm = ROC_historyC * 60;

% 1. Flight Path Angle vs Time
figure;
plot(Time_minutes, ClimbAngle_historyC, 'LineWidth', 1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Flight Path Angle (degrees)');
title('Flight Path Angle vs Time');

% 2. Rate of Climb vs Time
figure;
plot(Time_minutes, ROC_fpm, 'LineWidth', 1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Rate of Climb (ft/min)');
title('Rate of Climb vs Time');

% 3. Altitude vs Time
figure;
plot(Time_minutes, Altitude_ft, 'LineWidth', 1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Altitude (ft)');
title('Altitude vs Time');

% Drag and Thrust vs Time
figure;
plot(Time_minutes, Thrust_historyC, 'LineWidth', 1.5);
hold on;
plot(Time_minutes, Drag_historyC, 'LineWidth', 1.5);
grid on;
xlabel('Time (minutes)');
ylabel('Force (lbf)');
title('Thrust and Drag vs Time');
legend('Thrust','Drag','Location','best');


% FUNCTION: Calculate Aircraft Performance and T-D
function [difference,Thrust,Drag,FuelFlow,Power,CL,CD,RPM,FuelConsumption,Eta] = ...
    thrust_drag_difference(TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc)

    % Propeller model
    y = engine_propeller(MAP,TAS,altitude,TempF);
    % Convert KTAS to ft/s
    Velocity = TAS * 1.68781;
    % Dynamic pressure
    q = 0.5 * Density * Velocity^2;
    % Lift coefficient for level flight
    CL = Weight/(q*Area);
    % Drag coefficient
    CD = Cdfunc(CL);
    %RPM
    RPM = y.RPM;
    % Drag
    Drag = CD*q*Area;
    % Thrust
    Thrust = y.Thrust;
    % Power
    Power = y.Power;
    %BSFC
    BSFC = y.BSFC;
    % Fuel Flow
    FuelFlow = BSFC*Power;   % lb/hr
    % Thrust - Drag
    difference = Thrust - Drag;
    FuelConsumption = y.FuelConsumption;
    % Efficiency
    Eta = y.Eta;
end