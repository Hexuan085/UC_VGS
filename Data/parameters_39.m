function [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
    alpha_I, phi, delta_Omega,a_ln_chance,num_of_rand,line_flow_limit] = parameters_39

num_samples = 1;
num_of_gen = 10;
num_buses = 39;
num_of_lines = 46;
num_of_rand = 39;
coe = [1.0, 2.2, 1.9, 2.1, 2.9, 1.8, 1.4, 0.2, 0.8, 0.9];

a_ln = csvread('PTDF39.csv');
g_index = csvread('GEN39.csv');
r_index = csvread('RAND39.csv');
load_0 = csvread('load.csv');
load_0 = load_0 * 0.003

line_flow_limit = ones(num_of_lines,1)*50;
  line_flow_limit(1) = 49;
% line_flow_limit(2) = 100;
  line_flow_limit(3) = 100;
  line_flow_limit(4) = 90;
  line_flow_limit(5) = 150;
  line_flow_limit(46) = 95;
  line_flow_limit(42) = 95;
%   line_flow_limit(7) = 75;
%    line_flow_limit(13) = 40;
   line_flow_limit(37) = 90;
   line_flow_limit(33) = 95;
   line_flow_limit(26) = 140;
   line_flow_limit(27) = 160;
   line_flow_limit(24) = 100;
   line_flow_limit(25) = 100;

% cod = randn(39,1);
% D = [eye(num_of_gen);-eye(num_of_gen)];

delta_I = zeros(1,num_buses); %(std)^2, omega

c = zeros(num_buses,num_of_rand);
for r = 1:num_of_rand
    m = r_index(r);
    c(m,r) = 1;
    delta_I(m) = 1;
end

b = zeros(num_buses,num_of_gen);

alpha_I = zeros(1,num_buses);

num_of_alpha = 3;

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

phi = 1.65; %MPP_10%
%phi = 1.95; % 5%
delta_Omega = sum(delta_I);%(std)^2, Omega
a_ln_2 = a_ln.^2;
a_ln_f = delta_I + alpha_I.^2 * delta_Omega; 
a_ln_chance = zeros(1,num_of_lines);

for j = 1 : num_of_lines
    a_ln_chance(j) = sqrt(a_ln_2(j,:) * a_ln_f'); % std delta_f_j(omega)
end