clear
% 2024.9.6: 没有问题哦代码 affine policy是正确的


% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_300;
% 
%     [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
%       alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_39;
%     coe = coe';
% 
%  [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, ... 
%         alpha_I, phi, delta_Omega, a_ln_chance,num_of_rand,line_flow_limit] = parameters_118;
% [num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_500;
[num_of_gen, num_buses, num_of_lines, a_ln, load_0, b, c, coe, num_of_rand,line_flow_limit] = parameters_2383;

% '''
% 之前的问题主要在:
% 1. line-based的screening的时候, ptdf加了一些数之后会出问题
% 2.  如果不加的话, 约束会自动被处理, 约束的总数会有问题
% 3.  所以对于大规模系统, 就将自动处理之后的约束作为总数, 小规模系统, 就把所有load都当成决策变量.
% '''tas

l0 = load_0 * (1+0.00*unifrnd(-1,1,1,1));

l0 = load_0 * 0.2; %39, 300, 500: 1.2, 300, 118:0.8, 2383:0.2 | load range test: 39, 300, 500, 118:0.8, 2383:0.2
gen_upper = 100; %300, 39: 100, 118:50  

%Solving the original UC problem
[J_pre, x_ori_pre,u_ori_pre, ~] = Solve_UC_Semantic(num_of_gen, a_ln, b, coe,line_flow_limit,gen_upper,l0);

J_pre
% 
% limit = [0 == value(u_ori_pre); value(u_ori_pre) == 1; 0*value(u_ori_pre) == value(x_ori_pre); value(x_ori_pre) == 100*value(u_ori_pre); 
%     (l0' * c *0.1)'==(l0' * c *0.1)'; -(l0' * c *0.)'==-(l0' * c *0.1)'; a_ln * (b * value(x_ori_pre) -l0) <= -line_flow_limit*1+0.000005;
%     line_flow_limit*1-0.00005 <= a_ln * (b * value(x_ori_pre) -l0)];
% 
% sum(limit);

%Screening based on the relaxed UC problem.
% u_ori = value(u_ori_pre);
% x_ori = value(x_ori_pre);
load_range = 0.75;

[J_ori_mpp,x_ori_mpp,u_ori_mpp,d_ori_mpp, lp] = Solve_UC_GE(num_of_gen, a_ln, b, coe,line_flow_limit,gen_upper,l0,num_of_rand,c, J_pre,load_range);

try
tic
fprintf('screening\n')
solution = lp.solve();
toc
catch
solution = 0;
end

if class(solution) == "struct"
    tic
    J_MPP = min(solution.xopt.feval([0;0;0;0;0;0;0;0;0;0], 'obj'))
    toc
       
    elements = [];
    allElements = solution.mplpsol.activeConstraints;
    for i = 1:size(allElements,2)
        elements = union(elements, allElements{1,i});
    end
    elements
else
    J_MPP = 99999
end