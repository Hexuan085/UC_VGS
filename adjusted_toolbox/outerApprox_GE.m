function approx = outerApprox(obj)
%
% Computes the smallest axis-aligned hyperbox containing a given polyhedron

global MPTOPTIONS

if length(obj)>1
	for i = 1:length(obj)
		if nargout==1
			approx(i) = obj(i).outerApprox;
		else
			obj(i).outerApprox;
		end
	end
	return
end

 d = obj.Dim; %决策变量的个数
% fprintf('dimension')
% d

if isfield(obj.Internal, 'lb') && isfield(obj.Internal, 'ub')
	% reuse stored information
	lb = obj.Internal.lb;
	ub = obj.Internal.ub;

elseif obj.hasVRep
	% Vrep is easy without rays, just take min/max of vertices
	if isempty(obj.R_int)
		lb = min(obj.V_int, [], 1)';
		ub = max(obj.V_int, [], 1)';
	else
		% resort to ConvexSet/outerApprox for unbounded polyhedra
		approx = outerApprox@ConvexSet(obj);
		lb = approx.Internal.lb;
		ub = approx.Internal.ub;
	end
	% update properties of the input object
	obj.Internal.lb = lb;
	obj.Internal.ub = ub;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 这一块是被我注释啦
% elseif obj.isEmptySet()
%     lb = Inf(obj.Dim, 1);
%     ub = -Inf(obj.Dim, 1);
%     obj.Internal.lb = lb;
%     obj.Internal.ub = ub;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
	% for Hrep we have to solve 2 LPs per each dimension
%     fprintf('outer\n')
	H = obj.H_int;
	He = obj.He_int;
	f = zeros(1, d);
	LP.f = f;
	LP.A = H(:, 1:end-1);
	LP.b = H(:, end);
	LP.Ae = He(:, 1:end-1);
	LP.be = He(:, end);
	LP.lb = []; 
	LP.ub = [];
% 	LP.quicklp = true;
	d_load = 39; % 39:10 118:59 300:150 500:250 2383:500
    d_gen = 10; %39:10 118:54 300:69 500:90 2383:200
    gen_upper = 100;

	lb = zeros(d, 1);
    
 	ub = [20*ones(d_load, 1);gen_upper*ones(d_gen, 1);ones(d_gen, 1)];
   
    for k = 1: d_load
        lb(k) = -H(k+1,end);
        ub(k) =  H(k+1+d_load,end);
    end
       
    for g = 1: (size(LP.be)-1)
        g_index = find(He(g, 1:end-1));
        lb(g_index) = He(g, end);
        ub(g_index) = He(g, end);    
    end

	for i = d_load+1:d_load+d_gen
		% minimize
		LP.f = f;
		LP.f(i) = 1;
% 		sol = mpt_solve(LP);
% 		if sol.exitflag == MPTOPTIONS.OK
% 			lb(i) = sol.obj;
%         else
%             sol.obj
%               fprintf('lb')
% 		end
%         [~,fval_min] = linprog(LP.f,LP.A,LP.b,LP.Ae,LP.be);
% 		lb(i) = fval_min;

		% maximize
		LP.f(i) = -1;
		[~,fval_max] = linprog(LP.f,LP.A,LP.b,LP.Ae,LP.be);
        ub(i) = -fval_max;
% 		if sol.exitflag == MPTOPTIONS.OK
% 			ub(i) = -sol.obj;
%         else
%               fprintf('ub')
% 		end
	end
	
	% update properties of the input object
	obj.Internal.lb = lb;
	obj.Internal.ub = ub;
end

% construct output arguments
if nargout==1
	% return the bounding hyperrectangle as a Polyhedron object
	approx = Polyhedron([eye(d); -eye(d)], [ub; -lb]);
	approx.irredundantHRep = true;
	approx.Internal.lb = lb;
	approx.Internal.ub = ub;
end
