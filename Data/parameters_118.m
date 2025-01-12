function [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
    alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_118

num_samples = 1;
num_of_gen = 54;
num_buses = 118;
num_of_lines = 186;
num_of_rand = 118;  
% coe = 2.5 * ones(num_of_gen,1) %+ unifrnd(-2,1,num_of_gen,1);
coe = [1;2;0.5;0.8;3;10;1;1.5;2;4;1.9;1.5;2.5;0.9;1.4;5;2.8;0.4;0.1;0.6;1.3;2.1;0.7;0.9;0.8;10;1;1.5;2;4;2.3;1.1;1.3;1.2;0.9;4;1.4;1.2;2.1;3.4;1.1;0.6;0.8;0.7;1.4;0.2;0.8;0.5;3.2;4.1;1.2;1.5;2.1;4.3];

a_ln = csvread('PTDF118.csv');
g_index = csvread('GEN118.csv');
r_index = csvread('RAND118.csv');
load_0 = csvread('load_118.csv');
load_0 = load_0 * 0.02

line_flow_limit = ones(num_of_lines,1)*80;
line_flow_limit(1) = 20;
line_flow_limit(2) = 21;
line_flow_limit(3) = 20;
line_flow_limit(6) = 20;
line_flow_limit(8) = 20;
line_flow_limit(12) = 22;
line_flow_limit(15) = 20;
line_flow_limit(16) = 20;
line_flow_limit(20) = 20;
line_flow_limit(22) = 30;
line_flow_limit(23) = 30;
line_flow_limit(29) = 35;
line_flow_limit(30) = 100;
line_flow_limit(31) = 40;
line_flow_limit(32) = 30;
line_flow_limit(36) = 52;
% line_flow_limit(37) = 160;
line_flow_limit(37) = 50;
% line_flow_limit(38) = 140;
line_flow_limit(38) = 125;
line_flow_limit(41) = 55;
line_flow_limit(44) = 35;
line_flow_limit(44) = 35;

line_flow_limit(51) = 35;
line_flow_limit(52) = 35;
line_flow_limit(53) = 30;
line_flow_limit(54) = 45;
line_flow_limit(55) = 64;
line_flow_limit(66) = 40;
line_flow_limit(67) = 40;
line_flow_limit(78) = 45;
line_flow_limit(96) = 95;
line_flow_limit(97) = 55;
line_flow_limit(98) = 50;
line_flow_limit(99) = 50;
line_flow_limit(90) = 50;
line_flow_limit(104) = 145;
line_flow_limit(113) = 90;
line_flow_limit(112) = 53;
line_flow_limit(113) = 90;
line_flow_limit(114) = 50;
line_flow_limit(115) = 60;
line_flow_limit(116) = 70;
line_flow_limit(117) = 110;
line_flow_limit(118) = 84;
line_flow_limit(119) = 60;
line_flow_limit(120) = 30;
line_flow_limit(123) = 60;
line_flow_limit(127) = 90;
line_flow_limit(128) = 65;
line_flow_limit(30) = 75;
line_flow_limit(31) = 90;
line_flow_limit(32) = 75;
line_flow_limit(37) = 160;
line_flow_limit(38) = 130;
line_flow_limit(54) = 140;
line_flow_limit(186) = 55;

delta_I = zeros(1,num_buses); %(std)^2, omega

c = zeros(num_buses,num_of_rand);
for r = 1:num_of_rand
    m = r_index(r);
    c(m,r) = 1;
    delta_I(m) = 1;
end

b = zeros(num_buses,num_of_gen);

alpha_I = zeros(1,num_buses);

num_of_alpha = 5;

for g = 1:num_of_alpha
    m = g_index(g);
    b(m,g) = 1;
    alpha_I(m) = 1/num_of_alpha;
end

for g = num_of_alpha + 1:num_of_gen
    m = g_index(g);
    b(m,g) = 1;
    alpha_I(m) = 0;
end

% phi = 1.95; %5%
phi = 1.65; %MPP_10%
delta_Omega = sum(delta_I);%(std)^2, Omega
a_ln_2 = a_ln.^2;
a_ln_f = delta_I + alpha_I.^2 * delta_Omega; 
a_ln_chance = zeros(1,num_of_lines);

for j = 1 : num_of_lines
    a_ln_chance(j) = sqrt(a_ln_2(j,:) * a_ln_f'); % std delta_f_j(omega)
end

