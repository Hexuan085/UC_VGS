clear
% 2024.9.6: 没有问题哦代码 affine policy是正确的
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_300;
% 
  [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
      alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_39;
    coe = coe';
% 
%  [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
%         alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_118;
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_500;
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_2383;
output_cost = [];
output_unit = [];
input = [];
number_sample =600; %default 6000

while(size(input,2)<number_sample)

l0 = load_0 * 0.2; %39:1, 300, 500: 1.2, 118:0.8, 2383:0.2

l0 = l0 * (1+0.5*unifrnd(-1,1,1,1)); %base: (2383,0.2) (39, 118:1)
upper_gen = 100; %39, 500,300,2383:100, 118:50

x_ori_pre = sdpvar(num_of_gen, 1);
u_ori_pre = binvar(num_of_gen, 1);

J_ori_pre =  coe' * x_ori_pre;

C_ori_pre = [0*u_ori_pre <= x_ori_pre, x_ori_pre <= upper_gen*u_ori_pre, sum(b * x_ori_pre)== sum(l0), a_ln * (b * x_ori_pre -l0) >= -line_flow_limit*1, line_flow_limit*1 >= a_ln * (b * x_ori_pre -l0)];

lp = optimize(C_ori_pre,J_ori_pre);
J_pre = value(J_ori_pre);
unit_pre = value(u_ori_pre);

if J_pre>0
 input = [input, l0];
 output_cost = [output_cost;J_pre];
 output_unit = [output_unit,unit_pre];
end

fprintf('collected samples')
size(input,2)
end

input = input';
input=[input, output_unit'];

% filename_csv="unit_data_all500_GE_validation.csv";
% writematrix(input,filename_csv);