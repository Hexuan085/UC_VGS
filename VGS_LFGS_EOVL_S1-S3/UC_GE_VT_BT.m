clear
% 2024.8.6: 没有问题哦代码 affine policy是正确的
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

load_all = csvread("load_39_GE_cost.csv");
cost_pre_all = csvread("cost_pre_39.csv");
count_ge = zeros(100,1);
count_line = zeros(100,1);
solu_time_ori = zeros(100,1);
solu_time_now = zeros(100,1);
solution_gap = zeros(100,1);
screening_time_box = zeros(100,1);
screening_time_line = zeros(100,1);
screening_time = zeros(100,1);
total_limits_ge = zeros(100,1);
gen_upper = 100;

for i = 1:100
l0 = load_all(i,1:num_buses)';

J_real = load_all(i,num_buses+1);
J_pre = cost_pre_all(i);
load_range = 0;

[J_ori_mpp,x_ori_mpp,u_ori_mpp,d_ori_mpp, lp] = Solve_UC_GE(num_of_gen, a_ln, b, coe,line_flow_limit,gen_upper,l0,num_of_rand,c, J_pre,load_range);

% check feasibility
J_ori_check = coe' * x_ori_mpp;
u_check = binvar(num_of_gen, 1);
C_ori = [lp.A*[x_ori_mpp;u_check]<=lp.b, lp.Ae*[x_ori_mpp;u_check]==lp.be];
C_checck = [lp.Internal.A*[x_ori_mpp;u_check]<=lp.Internal.b, lp.Ae*[x_ori_mpp;u_check]==lp.be];

start_time = clock;
optimize(C_ori, J_ori_check);
J_real = value(J_ori_check); %只针对2383bus 因为coe是随机的
solu_time_ori(i) = etime(clock, start_time);

start_time = clock;
optimize(C_checck, J_ori_check);
solu_time_now(i) = etime(clock, start_time);
value(J_ori_check)

% record the removed constraints
count_ge(i) = lp.Internal.num_line_box;
count_line(i) = lp.Internal.removed_count;
screening_time_box(i) = lp.Internal.screening_time_box;
screening_time_line(i) = lp.Internal.screening_time_line;
screening_time(i) = lp.Internal.screening_time;
total_limits_ge(i) = lp.Internal.extrem_points_num;
solution_gap(i) = value(J_ori_check)-J_real;
end

fprintf("count_ge_total_limits")
total_removed_ge = sum(total_limits_ge)
fprintf("count_ge")
total_removed_ge_line = sum(count_ge)
fprintf("count_line")
total_removed_line = sum(count_line)
fprintf("solution_gap")
total_solu_gap = sum(solution_gap)
fprintf("solution_fast")
solution_fast = sum(solu_time_ori)/sum(solu_time_now)
fprintf("ori_time")
ori_solu_time = sum(solu_time_ori)
fprintf("now_time")
now_solu_time = sum(solu_time_now)
fprintf("screening_time")
total_scr_time = sum(screening_time)
fprintf("screening_time_box")
total_scr_time_box = sum(screening_time_box)
fprintf("screening_time_line")
total_scr_time_line = sum(screening_time_line)
