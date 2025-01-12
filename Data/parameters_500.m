function [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_500

num_samples = 1;
num_of_gen = 90;
num_buses = 500;
num_of_lines = 597;
num_of_rand = 500;
coe = [1;2;0.5;0.8;3;10;1;1.5;2;4;1.9;1.5;2.5;0.9;1.4;5;2.8;0.4;0.1;0.6;1.3;2.1;0.7;0.9;0.8;10;1;1.5;2;4;2.3;1.1;1.3;1.2;0.9;4;1.4;1.2;2.1;3.4;1.1;0.6;0.8;0.7;1.4;0.2;0.8;0.5;3.2;4.1;1.2;1.5;2.1;4.3;1;2;0.5;0.8;3;10;1;1.5;2;4;1.9;1.5;2.5;0.9;1.4;1.4;0.2;0.8;0.5;3.2;4.1;1.2;1.5;2.1;4.3;1;2;0.5;0.8;3;10;1;1.5;2;4;1.9];

a_ln = csvread('PTDF500.csv');
g_index = csvread('GEN500.csv');
r_index = csvread('RAND500.csv');
load_0 = csvread('load_500.csv');
load_0 = load_0 * 0.02
a_ln = a_ln;
line_flow_limit = ones(num_of_lines,1)*200;
line_flow_limit(1) = 40;
line_flow_limit(2) = 61;
line_flow_limit(3) = 70;
line_flow_limit(6) = 60;
line_flow_limit(8) = 135;
line_flow_limit(12) = 52;
line_flow_limit(15) = 60;
line_flow_limit(16) = 50;
line_flow_limit(20) = 70;
line_flow_limit(22) = 60;
line_flow_limit(23) = 60;
line_flow_limit(29) = 55;
line_flow_limit(30) = 200;
line_flow_limit(31) = 90;
line_flow_limit(32) = 80;
line_flow_limit(36) = 104;
% line_flow_limit(37) = 160;
line_flow_limit(37) = 150;
% line_flow_limit(38) = 140;
line_flow_limit(38) = 125;
line_flow_limit(41) = 95;
line_flow_limit(44) = 55;
line_flow_limit(44) = 55;

line_flow_limit(51) = 75;
line_flow_limit(52) = 69;
line_flow_limit(53) = 70;
line_flow_limit(54) = 95;
line_flow_limit(55) = 74;
line_flow_limit(66) = 50;
line_flow_limit(67) = 50;
line_flow_limit(78) = 55;
line_flow_limit(96) = 115;
line_flow_limit(97) = 55;
line_flow_limit(98) = 50;
line_flow_limit(99) = 50;
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
line_flow_limit(120) = 55;
line_flow_limit(123) = 60;
line_flow_limit(127) = 90;
line_flow_limit(128) = 65;
line_flow_limit(30) = 75;
line_flow_limit(31) = 90;
line_flow_limit(32) = 75;
line_flow_limit(37) = 160;
line_flow_limit(38) = 130;
line_flow_limit(54) = 140;
line_flow_limit(186) = 54;

c = zeros(num_buses,num_of_rand);
for r = 1:num_of_rand
    m = r_index(r);
    c(m,r) = 1;
end

b = zeros(num_buses,num_of_gen);

for g = 1:num_of_gen
    m = g_index(g);
    b(m,g) = 1;
end


