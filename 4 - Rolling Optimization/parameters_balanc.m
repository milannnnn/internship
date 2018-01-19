%clear all

%%%% model Bateries
%%%%

my_params = load('../../Data/System Params/params');

load('../../Data/Generated Data/6 - Power Flows/psi_loss');

C5= 10;     % capacitat C5
C20 =12;    % capacitat C20
C100 = 13;  % capacitat C100

C_Batt = my_params.Cap_bat*1e3;  % Capacidad de la bateria en Wh
SOC_o=my_params.SOC_init+4.2197e-04;     % SOC inicial pu

tau_Conv_Bat = 0.01; %  constant de temps del convertidor i la bateria
P_inv_bat    = my_params.P_bat_max*1e3; % potencia bateria en W

%%%% model PV
%%%%

tau_PV = 0.01;    %% constant de temps del INV + PV
P_sol_disp   = 1000;   %% constant per probar model no sera utilitzada en el real
P_inv_PV     = my_params.P_PV_inst*1e3;    %% potencia inv PV en W

%%%% model GS %%%%

pole_pairs =2;
P_nom_u_GS = my_params.P_dies_max*1e3;  % Potencia nominal de cada grupo
P_nom_GS = P_nom_u_GS*my_params.N_dies; % Potencia nominal total
fo = 50;                 % frecuencia inicial
fo_mec = fo/pole_pairs; % frecuencia inicial mecanica
Rendiment_viscos = 0.02;
K_freg=P_nom_u_GS*Rendiment_viscos/(2*pi*50)^2;

s = tf('s');
tao1=0.02;                          % valor del retraso de la combustión
tao2=0.1;                           %constante de tiempo del actuador
tao3=0.01;                          %valor de la constante de tiempo del filtro PI

J_Dies_u= 75;
Km = 1/K_freg;
tao4=J_Dies_u/K_freg;

Actuator=1/(1+tao2*s);              %Actuador modelitzado como un sistema de primer ordren
Combustion= exp(-tao1*s);           %rettraso de combustión
Crankshaft_dyn=Km/(1+tao4*s);       %Utilitzant Km= 1/K_freg (dinamic) i utilitzant tau = J/K_freg  (Tm-Te) = J*dw/dt+K_freg*w

%%Control of GS

Kp=160*2;
Ki=500*2;
FilterPI=(Ki+Kp*s)/((1+tao3*s)*s);

clear my_params;