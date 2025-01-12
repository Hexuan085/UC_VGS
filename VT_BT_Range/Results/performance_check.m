clear
% 2024.8.6: 没有问题哦代码 affine policy是正确的
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

% '''
% 之前的问题主要在:
% 1. line-based的screening的时候, ptdf加了一些数之后会出问题
% 2.  如果不加的话, 约束会自动被处理, 约束的总数会有问题
% 3.  所以对于大规模系统, 就将自动处理之后的约束作为总数, 小规模系统, 就把所有load都当成决策变量.
% '''

solu_time_ori = zeros(100,1);
solu_time_now = zeros(100,1);
solution_gap = zeros(100,1);
r = zeros(100,1);
gen_upper = 100;

load('2383_VT_BT_100.mat')

% l0 = load_0 * 0.2; %load range test: 39, 300, 500, 118:0.8, 2383:0.2
% index_start = num_of_gen*4 + num_of_rand*2;
% index_line = remove_row(remove_row > index_start);
% 
% index_line_1 = index_line(index_line <= index_start+num_of_lines)-index_start;
% 
% index_line_2 = index_line(index_line > index_start+num_of_lines)-index_start-num_of_lines;
% 

remove_row = lp.Internal.removed_rows.ineqlin;

solution_gap_current = 0;
i=1;
l0_1 = l0;
% abs(solution_gap_current)<0.0001 && 
while(i<=100)
start_time_1 = clock;
r(i)= 1*unifrnd(-1,1,1,1)+etime(clock, start_time_1);
r(i)
l0 = l0_1;
l0 = l0 + c * (c' * l0 * 1*r(i));

%%%%%%%% original problem
start_time = clock;
[J_real, x_ori_real,u_ori_real, ~] = Solve_UC_Semantic(num_of_gen, a_ln, b, coe,line_flow_limit,gen_upper,l0);
if (isnan(J_real)||J_real==0)
    continue;
end
solu_time_ori(i) = etime(clock, start_time);

%%%%%%%%%%%%%%% find Ax<b formulation for check feasibility
x_ori_mpp = sdpvar(num_of_gen, 1);
u_ori_mpp = sdpvar(num_of_gen, 1);
d_ori_mpp = sdpvar(num_of_rand, 1);

J_ori_mpp =  coe' * x_ori_mpp;
% coe' * x_ori_mpp <= 1.01 *J_pre, 
C_ori_mpp = [(-l0' * c * 0)' <= d_ori_mpp, (l0' * c * 0)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1,... 
    0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp),... 
    a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];

lp_check = Opt(C_ori_mpp, min(J_ori_mpp), d_ori_mpp, [x_ori_mpp,u_ori_mpp]);

%%%%%%%%%%%%%%%% solve the reduced problem
A=lp_check.A;
A(remove_row,:)=[];
check_b=lp_check.b;
check_b(remove_row)=[];

start_time = clock;
u_check = binvar(num_of_gen, 1);
x_ori_check = sdpvar(num_of_gen, 1);

J_ori_check =  coe' * x_ori_check;

C_checck = [A*[x_ori_check;u_check]<=check_b, lp_check.Ae*[x_ori_check;u_check]==lp_check.be];
optimize(C_checck, J_ori_check);
solu_time_now(i) = etime(clock, start_time);

%%%%%%%%%%%% record the gap
solution_gap_current = (value(J_ori_check)-J_real)/J_real;
solution_gap(i)=abs(solution_gap_current);

i= i+1
end

fprintf("solution_gap")
total_solu_gap = sum(solution_gap)
fprintf("solution_fast")
solution_fast = sum(solu_time_ori)/sum(solu_time_now)
fprintf("ori_time")
ori_solu_time = sum(solu_time_ori)
fprintf("now_time")
now_solu_time = sum(solu_time_now)
