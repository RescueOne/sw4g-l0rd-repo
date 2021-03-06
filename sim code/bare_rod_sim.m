% -------------------
% BARE ROD SIMULATION
% -------------------
% Details:
% rod is completely free, no insulators
% Power loss (along entire rod, and end)
%     - radiation
%     - convection
% Power in
%     - power resistor (not considered power loss out back)

% ====================
% == APPROIXIMATION ==
% ====================

% Setting the time and positions steps, and initial and final values
Nx = 140; %Number of steps in length
Nt = 100000; %Number of steps in time
t0 = 0; %Start time (s)
tf = 2800; %End time (s)
x0 = 0; %Start length (m)
xf = 0.3; %End length (m)

% Calculating the change is postion and time
dx = (xf - x0)/(Nx);
dt = (tf - t0)/(Nt);

% ===============
% == CONSTANTS ==
% ===============

a = 0.011; %Radius of the rod (m)
SBc = 5.67e-8; %Stefan-Boltzmann constant (W/(m^2K^4))
rho = 2.7e3; %Density of Al (kg/m^3)

% Constant Values we modify for a better fit
kc = 14; %Convection coefficient of horizontal Al rod (W/(m^2K))
k = 190; %Constant of conductivity of Al (W/(mK))
e = 0.10; %Emmisivity of sandblasted Al rod
Cp = 950; %Specific heat capacity of Al (J/(K kg))
Pinl = 7; %Power into the left side of the rod (W)

% Other values we can modify
Tamb = 273+27; %Ambient temperature (K)

% Predefined functions for changes in temperature (loss and gain)
dT_convec = @(Tx) (kc*2*(Tx-Tamb)*dt)/(Cp*rho*a); %Temperature change due to convection (K)
dT_rad = @(Tx) (e*SBc*2*(Tx.^4-Tamb^4)*dt)/(Cp*rho*a); %Temperature change due to radiation (K)
dT_convec_end = @(Tx) (kc*(Tx-Tamb)*dt)/(Cp*rho*dx);
dT_rad_end = @(Tx) (e*SBc*(Tx.^4-Tamb^4)*dt)/(Cp*rho*dx);
dT = @(P) (P * dt)/(Cp * pi*a^2*dx*rho); %Temperature change in chunk (K)

% ==================
% == START OF SIM ==
% ==================

% Creating the T matrix and defining its memory
T = zeros(Nx, Nt); %Array o temp over time, indices are (x,t)

% Initial
T(:,1) = ones(Nx,1) * Tamb; %Set all temperatures to Tamb

for time = 1:Nt-1
    %power in to rod
    T(1,time+1)=T(1,time)+dT(Pinl)+((k/(Cp*rho))*(T(2,time)-T(1,time))./dx^2)*dt;
    
    % Temperature changes due to conduction
    T(2:Nx-1,time+1)=T(2:Nx-1,time)+(k/(Cp*rho))*((T(3:Nx,time)-2*T(2:Nx-1,time)+T(1:Nx-2,time))./dx^2)*dt;
    T(Nx,time+1) = T(Nx,time)-((k/(Cp*rho))*(T(Nx,time)-T(Nx-1,time))./dx^2)*dt;

    % Temperature loss due to Radiation adn Convection along the rod
    T(1:Nx,time+1)=T(1:Nx,time+1) - dT_convec(T(1:Nx,time+1)) - dT_rad(T(1:Nx,time+1));

    % Only power loss due to rad and convection at end of rod
    T(Nx,time+1)=T(Nx,time+1) - dT_convec_end(T(Nx,time+1)) - dT_rad_end(T(Nx,time+1));
end

% ==============
% == PLOTTING ==
% ==============

timeSim = linspace(0,tf,Nt);

% Plot of all points
% for position = 1:Nx
%     plot(timeSim,(T(position,:)-273));
%     hold on;
% end

plot(timeSim,(T(1,:)-273));
hold on
plot(timeSim,(T(Nx,:)-273));
plot(timeSim,(T(floor(Nx/3),:)-273));
plot(timeSim,(T(floor(Nx*2/3),:)-273));

xlabel('Time (Seconds)');
ylabel('Temp (C)');

timeDATA = timeDATA(1:size(T1, 2));
plot(timeDATA, T1, 'c', timeDATA, T2, 'y', timeDATA, T3, 'g', timeDATA, T4, 'r', timeDATA, T5, 'm')

hold off

% =============
% == CHI ^ 2 ==
% =============

% Calculate chai squared values
X1 = zeros(1,length(timeDATA));
X2 = zeros(1,length(timeDATA));
X3 = zeros(1,length(timeDATA));
X4 = zeros(1,length(timeDATA));

T = T-273; % Converting to Celsius

for tindex = 1:length(timeDATA)
   % Getting correct indices
   tcur = timeDATA(tindex);
   tmp = abs(timeSim-tcur);
   [idx idx] = min(tmp); %index of closest value
   TData1 = T1(tindex);
   TSim1 = T(Nx,idx);
   X1(tindex) = (TData1-TSim1)^2;
   
   TData2 = T2(tindex);
   TSim2 = T(floor(Nx*2/3),idx);
   X2(tindex) = (TData2-TSim2)^2;
   
   TData3 = T3(tindex);
   TSim3 = T(floor(Nx/3),idx);
   X3(tindex) = (TData3-TSim3)^2;
   
   TData4 = T4(tindex);
   TSim4 = T(1,idx);
   X4(tindex) = (TData4-TSim4)^2;
end

% Summing all chi^2 then totalling the values
Xsquare1 = sum(X1)/length(X1)
Xsquare2 = sum(X2)/length(X2)
Xsquare3 = sum(X3)/length(X3)
Xsquare4 = sum(X4)/length(X4)
XsquareTot = (Xsquare1^2 + Xsquare2^2 + Xsquare3^2 + Xsquare4^2)/4

