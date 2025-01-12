%20240927 line-based+gen-based的screening 没问题 能够得到和非函数形式相同的结果
function [J_ori_mpp,x_ori_mpp,u_ori_mpp,d_ori_mpp, lp]= Solve_UC_GE(num_of_gen, a_ln, b, coe,line_flow_limit,gen_upper,l0,num_of_rand,c,J_pre,load_range)

x_ori_mpp = sdpvar(num_of_gen, 1);
u_ori_mpp = sdpvar(num_of_gen, 1);
d_ori_mpp = sdpvar(num_of_rand, 1);

J_ori_mpp =  coe' * x_ori_mpp;
% coe' * x_ori_mpp <= 1.01 *J_pre, 
C_ori_mpp = [(-l0' * c * load_range)' <= d_ori_mpp, (l0' * c * load_range)' >= d_ori_mpp,  0 <= u_ori_mpp, u_ori_mpp <= 1,... 
    0*u_ori_mpp <= x_ori_mpp, x_ori_mpp <= gen_upper*u_ori_mpp, sum(b * x_ori_mpp) == sum(l0+c*d_ori_mpp),... 
    a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp) >= -line_flow_limit*1,line_flow_limit*1 >= a_ln * (b * x_ori_mpp -l0-c*d_ori_mpp)];

% 39: 1: cost, 2-21: rand_load, u:22-41, ge: 42-61, limit:62-153.
% 118: 1:cost, 2-119: rand_load, u:120-159, ge: 160-199, limit: 200-571.
% 300: 1:cost, 2-21:rand_load, u:22-81, ge: 82-141, limit:142-963.

lp = Opt(C_ori_mpp, min(J_ori_mpp), d_ori_mpp, [x_ori_mpp,u_ori_mpp]);
