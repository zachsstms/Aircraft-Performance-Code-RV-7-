% Alexander Vasilakis
% Aircraft Performance
% Assignment 1

close all
clear all
clc

addpath('C:\Users\axvas\OneDrive\Desktop\SeniorAeroMatlab\AircraftPerformance');

% Plane Constants
Area = 121; %sqft
MTOW = 1800; %lbs
% Usable Fuel 
FuelW = 244.8; %lbs Usable Fuel
EmptyW = 1168.45; %lbs
CargoW = 99.208; %lbs

% Hold Alt and Map Constant
altitude = 1000;

Cdfunc = @(CL) 0.024292 + 1.6647e-9*CL + 0.071696*CL^2;


[Pressure,Density,Temperature,SoS] = stdatm_vasilakis(altitude);

TempF = (Temperature - 273.15)*9/5 + 32;

%Example Values
RPM = 2400;
MAP = 23.25;
altitude = 1700; %ft
temp = 13;
TAS = 100; %ktas
plotar = 1;

% Engine Deck Input RPM MAP Alt PLOTAR, Output [power, consumption]
[ShaftPower,consumption] = engine_O360(RPM,MAP,altitude,temp,plotar);

% Propeller Deck: Input MAP, TAS, h, temp, Output: [Power,Thrust,Eta
% RPM,Fuel Consumption BSFC].
y = engine_propeller(MAP,TAS,altitude,temp);


%% Validate METHOD with POH
% Steady Level Flight, Standard Day
clear all
clc
addpath('C:\Users\axvas\OneDrive\Desktop\SeniorAeroMatlab\AircraftPerformance');

% Plane Constants
Area = 121; %sqft
MTOW = 1800; %lbs
% Usable Fuel 
FuelW = 244.8; %lbs Usable Fuel
EmptyW = 1168.45; %lbs
CargoW = 99.208; %lbs
PassengerW = 287; %lbs to get to about MTOW
PayloadW = CargoW + PassengerW;
CurrentFuelW = FuelW;

% Hold Alt and Map Constant
altitude = 8000;
MAPrange = linspace(17,25,30);

Cdfunc = @(CL) 0.024292 + 1.6647e-9*CL + 0.071696*CL^2;
% Atmosphere
[Pressure,Density,Temperature,SoS] = stdatm_vasilakis(altitude);
TempF = (Temperature - 273.15)*9/5 + 32;

% Calculating Fuel Flow and TAS
for i = 1:length(MAPrange)
% Initial TAS guess
TAS_current = 120;   % knots
MAP = MAPrange(i);
% Current Aircraft Weight
    Weight = EmptyW + PayloadW + CurrentFuelW;

% Function for T - D
fun = @(TAS) thrust_drag_difference( ...
        TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);

% Solve T = D using previous TAS as the initial guess
TAS_current = fzero(fun,TAS_current);
[~,Thrust,Drag,FuelFlow,Power,CL,CD,RPM,FuelConsumption] = thrust_drag_difference(TAS_current,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);

Tasalt(i) = TAS_current;
FuelFlowalt(i) = FuelConsumption;

end

%Table of Cruise Performance Endurance/Range Digitized from OH
% Left table

MAP = [17.5 18.5 19.5 20.5 21 21.5 22 22.8 22.8 22.8 23 24.5 24.5 24.5 24.6 24.6];
Altitude = [8000 8000 8000 8000 6000 6000 6000 8000 8000 8000 6000 6000 6000 6000 6000];
RPM = [1750 1850 1950 2050 2100 2150 2200 2250 2350 2450 2300 2200 2300 2400 2100 2500];
TAS = [114 131 140 145 143 153 148 164 165 167 154 162 164 166 160 167];
Range = [920 815 775 760 770 730 710 690 690 650 675 665 655 615 690 595];
Endurance = [8.1 6.2 5.5 5.2 5.4 4.8 4.8 4.2 4.2 3.9 4.4 4.1 4.0 3.7 4.3 3.5];

% POH DATA for Fuel FLow and KTAS
% Cruise Performance Endurance/Range Chart
% For altitude = 8000 ft
MAP_8000 = [17.5 18.5 19.5 20.5 21.5 22.8 22.8 22.8];
TAS_8000 = [114 131 140 145 153 164 165 167];
FuelFlow_8000 = [5 6.5 7.6 7.9 8.5 9.5 9.8 10.2];

% For altitude = 6000 ft
MAP_6000 = [21 22 23 24.5 24.5 24.5 24.6 24.6];
TAS_6000 = [143 148 154 162 164 166 160 167];
FuelFlow_6000 = [7.8 8.3 9.1 9.7 10 11 11.2 11.2];

% MY Model for TAS AND FF
% 6000
TAS6000 = [123.842392238811,126.199891251950,128.430026972150,130.663187651340,132.644917300504,134.577009951153,136.459173782641,138.128072991261,139.911481652862,141.795210168948,143.387874667800,144.843725881103,146.197347081415,...
    147.601554515326,148.942010852123,149.698529514522,150.521694632918,151.874649420607,153.105631258307,154.383435957675,155.672232165115,156.845646786768,158.239692809395,159.480741120457,160.705812760204,162.068342085101,163.272210973410,164.482746538276,165.699890165662,166.929327725842];
FF6000 = [6.66858451504455	6.89123751244143	7.12505729201778	7.36597219538609	7.59614135859732	7.82379969480104	8.04911515549895	8.26475964640323	8.48533697657069	8.72546591197104	8.95923866014838	9.20272486259086	9.44663399127707	9.70841276756029	9.97124709907145	10.2005777438513...
    10.4382023747812	10.7200155812398	11.0023471276799	11.2916609008926	11.5850281357429	11.9080378981392	12.3064153255583	12.7008866581270	13.0997338009733	13.5209168044337	13.9456265560419	14.3890326837165	14.8480936089401	15.3201994165670];

% 8000
TAS8000 = [131.311140832132	133.393901994353	135.431588219767	137.577798496309	139.493160950360	141.338718505246	143.165227428162	144.703183121874	146.310138331626	147.766280166622	149.181991828418	149.653284006325	151.075234080326	152.353442851847	153.699146230253	155.076064469618...
    156.493676235869	158.011386124698	159.401173229841	160.756226365760	162.087852307414	163.562395837600	164.851811445834	166.111932720120	167.340467031982	168.534444392260	169.777892779101	171.082554341939	172.414713266799	173.787022156397];
FF8000 = [7.24063945857640	7.47336013063378	7.70394132201433	7.93983720950565	8.16558219827992	8.38827595010117	8.61794102251635	8.85472433742840	9.10559122711993	9.35055585512130	9.59757216236257	9.81480209795494	10.0842900472622	10.3501465831843	10.6255097765750	10.9091152024207...
    11.2442379936094	11.6464735796048	12.0409419550218	12.4350637847351	12.8435121592542	13.2817483802847	13.6965087333024	14.1087271545873	14.5400442812186	14.9832478862396	15.4618702973488	15.9642062849550	16.5190476929995	17.1270242151917];

% My Model for range endurance and KTAS
% 8000
MAP_8000Sim = [17.5 18.5 19.5 20.5 21.5 22.8];
Range_8000Sim = [724 686.38 646.16 605.68 562.68 501.68];
Endurance_8000Sim = [316 286.5 259.83 237.17 213.5 182.83]./60; % convert from min to hr

%6000
MAP_6000Sim = [21 22 23 24.6];
Range_6000Sim = [605.45 567.72 527.1 459.81];
Endurance_6000Sim = [241.83 220.67 199 166.17]./60; % convert from min to hr

% POH DATA FOR RANGE ENDURANCE AND KTAS
% alt = 8000
MAP_8000R = [17.5 18.5 19.5 20.5 21.5 22.8];
TAS_8000R = [110 130 140 145 153 170];
Range_8000R = [930 815 780 770 730 690]; %nm
Endurance_8000R = [8 6.2 5.5 5.2 4.8 4.2]; %hr

% alt = 6000
MAP_6000R = [21 22 23 24.6];
TAS_6000R = [143 150 160 170];
Range_6000R = [780 710 680 690];
Endurance_6000R = [5.4 4.7 4.4 4.3];

% True Airspeed and Fuel Flow vs MAP
figure
plot(MAPrange,TAS6000)
hold on
plot(MAPrange,TAS8000)
plot(MAP_6000,TAS_6000,'o')
plot(MAP_8000,TAS_8000,'o')
xlabel('Manifold Presusre [inHg]')
ylabel('True Airspeed [KTAS]')
legend('Model, Alt = 6000','Model, Alt = 8000','POH Altitude = 6000','POH Altitude = 8000','Location','best')
title('TAS vs MAP')

figure
plot(MAPrange,FF6000)
hold on
plot(MAPrange,FF8000)
plot(MAP_6000,FuelFlow_6000,'o')
plot(MAP_8000,FuelFlow_8000,'o')
xlabel('Manifold Presusre [inHg]')
ylabel('Fuel Flow [USGal/hr]')
legend('Model, Alt = 6000','Model, Alt = 8000','POH Altitude = 6000','POH Altitude = 8000','Location','best')
title('Fuel Flow vs MAP')


figure
plot(MAP_8000Sim,Range_8000Sim)
hold on
plot(MAP_6000Sim,Range_6000Sim)
plot(MAP_8000R,Range_8000R)
plot(MAP_6000R,Range_6000R)
xlabel('Manifold Presusre [inHg]')
ylabel('Range [nm]')
legend('Model, Alt = 8000','Model, Alt = 6000','POH Altitude = 8000','POH Altitude = 6000','Location','best')
title('Range vs MAP')

figure
plot(MAP_8000Sim,Endurance_8000Sim)
hold on
plot(MAP_6000Sim,Endurance_6000Sim)
plot(MAP_8000R,Endurance_8000R)
plot(MAP_6000R,Endurance_6000R)
xlabel('Manifold Presusre [inHg]')
ylabel('Endurance [Hr]')
legend('Model, Alt = 8000','Model, Alt = 6000','POH Altitude = 8000','POH Altitude = 6000','Location','best')
title('Endurance vs MAP')

%% Build The Integrator
% Steady Level Flight, Standard Day
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

% Hold Alt and Map Constant
altitude = 6000;

Cdfunc = @(CL) 0.024292 + 1.6647e-9*CL + 0.071696*CL^2;

% Atmosphere
[Pressure,Density,Temperature,SoS] = stdatm_vasilakis(altitude);
TempF = (Temperature - 273.15)*9/5 + 32;


MAP = 24.6;

% Tolerance of Steady lvl Flight
tolerance = 1; %lbf
TASRANGE = linspace(30,200,1000);

% Time Integration
t = 0;
dt = 30; %seconds
Distance = 0; % ft

% TAS search limits
TASmin = 30;            % knots
TASmax = 200;           % knots

% Current Fuel
CurrentFuelW = FuelW;

% Results arrays
Time_history = [];
Fuel_history = [];
Weight_history = [];
TAS_history = [];
Thrust_history = [];
Drag_history = [];
Power_history = [];
CL_history = [];
CD_history = [];
Distance_history = [];

% Initial TAS guess
TAS_current = 120;   % knots

% Time Marching Loop
while CurrentFuelW > 0

    % Current Aircraft Weight
    Weight = EmptyW + PayloadW + CurrentFuelW;

    % Function for T - D
    fun = @(TAS) thrust_drag_difference( ...
        TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);

    % Solve T = D using previous TAS as the initial guess
   TAS_current = fzero(fun,TAS_current);

[~,Thrust,Drag,FuelFlow,Power,CL,CD,RPM,FuelConsumption] = thrust_drag_difference(TAS_current,Weight,MAP,altitude,TempF,Density,Area,Cdfunc);
    % Convert TAS to ft/s
    Velocity = TAS_current * 1.68781;

    % Fuel burned
    FuelBurned = FuelFlow/3600 * dt;

    % Distance traveled
    Distance = Distance + Velocity*dt;

    % Save results
    Time_history(end+1) = t;
    Fuel_history(end+1) = CurrentFuelW;
    Weight_history(end+1) = Weight;
    TAS_history(end+1) = TAS_current;
    Thrust_history(end+1) = Thrust;
    Drag_history(end+1) = Drag;
    Power_history(end+1) = Power;
    CL_history(end+1) = CL;
    CD_history(end+1) = CD;
    Distance_history(end+1) = Distance;

    % Update fuel
    CurrentFuelW = CurrentFuelW - FuelBurned;

    if CurrentFuelW < 0
        CurrentFuelW = 0;
    end

    % Update time
    t = t + dt;
end

% Display Final Results
fprintf('\n--- Final Results ---\n')
fprintf('Flight Time = %.2f min\n',t/60)
fprintf('Distance = %.2f nautical miles\n',Distance/6076.12) %converts ft to nm
fprintf('Fuel Remaining = %.2f lb\n',CurrentFuelW)

% Plot Results

figure
plot(Time_history/60,TAS_history)
xlabel('Time (min)')
ylabel('TAS (knots)')
title('True Airspeed vs Time')
grid on

figure
plot(Time_history/60,Fuel_history)
xlabel('Time (min)')
ylabel('Fuel Remaining (lb)')
title('Fuel Remaining vs Time')
grid on

figure
plot(Time_history/60,Weight_history)
xlabel('Time (min)')
ylabel('Aircraft Weight (lb)')
title('Aircraft Weight vs Time')
grid on

figure
plot(Time_history/60,Distance_history/6076.12)
xlabel('Time (min)')
ylabel('Distance (NM)')
title('Distance vs Time')
grid on

figure
plot(Time_history/60,Drag_history)
xlabel('Time (min)')
ylabel('Drag (lbf)')
title('Drag vs Time')
grid on

% FUNCTION: Calculate Aircraft Performance and T-D
function [difference,Thrust,Drag,FuelFlow,Power,CL,CD,RPM,FuelConsumption] = ...
    thrust_drag_difference( ...
    TAS,Weight,MAP,altitude,TempF,Density,Area,Cdfunc)

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
end