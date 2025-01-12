% clear

% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_300;
% 
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
%       alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_39;
%     coe = coe';
% 
%  [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
%         alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_118;
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_500;
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_2383;

% load("unit_pre_2383_cost.m");
count_ge = zeros(100,1);
count_line = zeros(100,1);
solu_time_ori = zeros(100,1);
solu_time_now = zeros(100,1);
solution_gap = zeros(100,1);
screening_time_box = zeros(100,1);
screening_time_line = zeros(100,1);
screening_time = zeros(100,1);
gen_upper = 100;

for i =1:100
l0 = xtest(i,:)';

index_status_off = find(pred_unit_total(i,:)==0);
index_status_on = find(pred_unit_total(i,:)==1);

x_ori_mpp = sdpvar(num_of_gen, 1);
u_ori_mpp = sdpvar(num_of_gen, 1);
d_ori_mpp = sdpvar(num_of_rand, 1);

J_ori_mpp =  coe' * x_ori_mpp;
load_range = 0;
% cost+unit
C_ori_mpp = [coe' * x_ori_mpp<=output_cost(num_train_sample+i)*1.05, (-l0' * c *load_range)' <= d_ori_mpp, (l0' * c *load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1, u_ori_mpp(index_status_off)==0, u_ori_mpp(index_status_on)==1,... 
    0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp), a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];
% 
% unit
% C_ori_mpp = [(-l0' * c *load_range)' <= d_ori_mpp, (l0' * c *load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1, u_ori_mpp(index_status_off)==0, u_ori_mpp(index_status_on)==1,... 
%     0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp), a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];

% unit_all
% C_ori_mpp = [(-l0' * c *load_range)' <= d_ori_mpp, (l0' * c *load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1, u_ori_mpp==ytest(i,:)',... 
%     0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp), a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];

% cost
% C_ori_mpp = [coe' * x_ori_mpp<=output_cost(num_train_sample+i)*1.05, (-l0' * c *load_range)' <= d_ori_mpp, (l0' * c *load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1, ... 
%     0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp), a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];
% 
% original
% C_ori_mpp = [(-l0' * c *load_range)' <= d_ori_mpp, (l0' * c *load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1, ... 
%     0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp), a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];

% 39: 1: cost, 2-21: rand_load, u:22-41, ge: 42-61, limit:62-153.
% 118: 1:cost, 2-119: rand_load, u:120-159, ge: 160-199, limit: 200-571.
% 300: 1:cost, 2-21:rand_load, u:22-81, ge: 82-141, limit:142-963.
% C_ori_mpp = [0 <= u_ori_mpp, u_ori_mpp <= 1, 0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= 100*u_ori_mpp, sum(b * x_ori_mpp)== sum(l0), a_ln * (b * x_ori_mpp -l0) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0)];

% optimize(C_ori_mpp, J_ori_mpp)
% value(J_ori_mpp)

lp = Opt(C_ori_mpp, min(J_ori_mpp), d_ori_mpp, [x_ori_mpp,u_ori_mpp]);

% check feasibility
J_ori_check = coe' * x_ori_mpp;
u_check = binvar(num_of_gen, 1);
C_ori = [lp.A*[x_ori_mpp;u_check]<=lp.b, lp.Ae*[x_ori_mpp;u_check]==lp.be];
C_checck = [lp.Internal.A*[x_ori_mpp;u_check]<=lp.Internal.b, lp.Ae*[x_ori_mpp;u_check]==lp.be];

start_time = clock;
optimize(C_ori, J_ori_check);
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
solution_gap(i) = abs((value(J_ori_check)-output_cost(num_train_sample+i))/output_cost(num_train_sample+i));

end

fprintf("count_ge")
total_removed_ge = sum(count_ge)
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
