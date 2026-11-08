% Alex Vasilakis
% Performance
% Performance Assignment 2 ATTEMPT 2
close all
clear all
clc


%% OPTIMAL CLIMB AND DESCENT GIVEN A TAS AND MAP RANGE
clear all
close all 
clc
% X = altitude
% Y = Climb Rate, Feet per minute
x = [4830.0, 3634.2, 6143.0, 7456.0, 8675.3, 9941.4, ...
     10902.7, 11770.2, 12755.0, 13716.3, 14607.3];

y = [1237.9, 1330.8, 1191.5, 1185.3, 1070.8, 1015.1, ...
     913.0, 854.2, 854.2, 829.4, 690.1];

% Assume Thrust is aligned with flight path
% Climb and Descent Solver: Constant 

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
TAS = 100; %KTIS
Vairft_s = TAS * 1.68781; %ft/s

% Given altitude
altitude = 5000; % ft
altitudem = altitude*.3048; % m

[T,~,~,rho,~,~] = atmosisa(altitudem);

% Maybe change weight for timestep
%MAPRANGE = 13.5 - 32;
%MAP = 18;
%MAPrange = linspace(13.5,32,40);
MAPrange = 32;
%TASRANGE = linspace(70,160,90);
TASRANGE = 85;
ALTRANGE = linspace(0,10000,11);
for k = 1:length(x)
for j = 1:length(TASRANGE)
for i =1:length(MAPrange)
altitude = x(k);
altm = altitude*.3048;
Weight = MTOW;
MAP = MAPrange(i);
TAS = TASRANGE(j);
[T,~,~,rho,~,~] = atmosisa(altm);
Density = rho/515.379; % Get Density in slugs/ft^3
TempF = 1.8*(T-273.15)+32;
[TDDifference,~,~,~,~,~,~,~,~,~] = thrust_drag_difference(TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);
Tdrange(i,j) = TDDifference;
end
end

%
% MAP is row, TAS RANGE is col
[TDmaxClimb,idx] = max(Tdrange(:));
[TDmaxDescent,idx2] = min(Tdrange(:));

[rowMaxC, colMaxC] = ind2sub(size(Tdrange), idx);
[rowMinD, colMinD] = ind2sub(size(Tdrange), idx2);

BestAngleC(k,:) = asind(TDmaxClimb/Weight);
BestAngleD(k,:) = asind(TDmaxDescent/Weight);
BestROCC(k,:) = 1.68781*sind(BestAngleC(k,:)) * TASRANGE(colMaxC);
BestROCD(k,:) = 1.68781*sind(BestAngleD(k,:)) * TASRANGE(colMinD);
BestMAPC(k,:) = MAPrange(rowMaxC);
BestMAPD(k,:) = MAPrange(rowMinD);
BestTASC(k,:) = TASRANGE(colMaxC);
BestTASCD(k,:) = TASRANGE(colMinD);

disp(k);
fprintf('Maximum Climb Angle:\n');
fprintf('  T - D = %.2f lbf\n', TDmaxClimb);
fprintf('  Flight Path Angle = %.2f deg\n', BestAngleC(k));
fprintf('  Rate of Climb = %.0f ft/min\n',BestROCC(k)*60);
fprintf('  Manifold Pressure = %.2f \n', BestMAPC(k));

fprintf('Maximum Descent Angle:\n');
fprintf('  T - D = %.2f lbf\n', TDmaxDescent);
fprintf('  Flight Path Angle = %.2f deg\n', BestAngleD(k));
fprintf('  Rate of Descent = %.0f ft/min\n',BestROCD(k)*60);
fprintf('  Manifold Pressure = %.2f \n', BestMAPD(k));
% POH COMPARISON
end
figure
hold on
plot(x,y,'o')
plot(x,BestROCC*60)
xlabel('Altitude')
ylabel('ROC [ft/min]')
legend('POH','Solver')
hold off




%% ROC,FLIGHT ANGLE, VS VTAS AT A GIVEN ALTITUDE AND MAP
clear all
close all
% Plane Constants
Area = 121; %sqft
MTOW = 1800; %lbs
% Usable Fuel 
FuelW = 244.8; %lbs Usable Fuel
EmptyW = 1168.45; %lbs
CargoW = 99.208; %lbs
PassengerW = 287; %lbs to get to about MTOW
PayloadW = CargoW + PassengerW;
Weight = MTOW;
addpath('C:\Users\axvas\OneDrive\Desktop\SeniorAeroMatlab\AircraftPerformance');

% % FLIGHT MANUAL DATA
% Best Glide: 85 KIAS
% Best Angle of Climb: 70 KIAS
% BEst Rate of Climb: 85 KIAS

% CD function
Cdfunc = @(CL) 0.024292 + 1.6647e-9*CL + 0.071696*CL^2;


% Maybe change weight for timestep
MAP = 25;
TASRANGE = linspace(70,160,90);
altitude = 5000;
% Given altitude
altitudem = altitude*.3048; % m

[T,~,~,rho,~,~] = atmosisa(altitudem);
Density = rho/515.379; % Get Density in slugs/ft^3
TempF = 1.8*(T-273.15)+32;


for i = 1:length(TASRANGE)
TAS = TASRANGE(i);
[TDDifference,~,~,~,~,~,~,~,~,~] = thrust_drag_difference(TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);
Tdrange = TDDifference;

FPA(i) = asind(Tdrange/Weight);
ROC(i) = 1.68781*sind(FPA(i)) * TASRANGE(i);
end

% Plotting
figure
plot(TASRANGE,FPA)
xlabel('TAS [kts]')
ylabel('Flight Path Angle [degrees]')
title('Flight Path Angle vs TAS')
figure
plot(TASRANGE,ROC*60)
xlabel('TAS [kts]')
ylabel('Rate of Climb [ft/min]')
title('Rate of Climb vs TAS')








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

%% POH COMPARISON
figure
hold on
plot(x,y,'o')
plot(x,BestROCC*60)
xlabel('Altitude')
ylabel('ROC [ft/min]')
legend('POH','Solver')