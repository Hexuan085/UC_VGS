function [obj, sol, extrem_points_num, removed_count, screening_time_box, screening_time_line, screening_time,num_line_box] = minHRep(obj)
% MINHREP Compute the irredundant H-representation of a polyhedron
%
% P.minHRep
% sol = P.minHRep
%
% Compute an irredundant H-representation of the polyhedron:
%
%   P = {x | H*[x;-1] <= 0} cap {x | He*[x;-1] = 0}
%
% If an H-rep is already known, then this function does redundancy
% elimination.
%
% Returns:
%  sol - Structure with fields
%   H       - Irredundant inequality description of P
%   He      - Affine hull of P
%   I       - logical indices of redundant rows
%
 d_load = 39;
 d_gen = 10;
 cost = 0;
 line_index_start = cost+d_load*2+d_gen*4;
 extrem_points_num = 0; %被VT移除的约束总数
 screening_time_box = 0;
 num_line_box = 0; %VT找到的line limit约束数目
 removed_count = 0; %BT找到的line limit约束数目
 screening_time_line = 0;
 
 bounding_box = true;
 rayshooting = false;
 BT_status = true;
global MPTOPTIONS
if isempty(MPTOPTIONS)
	MPTOPTIONS = mptopt;
end

% fprintf('minHRep\n')

if numel(obj)>1
	% element-wise operation for arrays
	if nargout==0
		obj.forEach(@minHRep);
	elseif nargout==1
		obj = obj.forEach(@minHRep);
	else
		[obj, sol] = obj.forEach(@minHRep);
	end
	return
end

if ~obj.hasHRep
	% convert to Hrep if necessary
	obj.computeHRep();
    fprintf('computeHRep')
end
if obj.irredundantHRep
	% nothing to do here
	if nargout>1
		sol.H = obj.H_int;
		sol.He = obj.He_int;
		sol.I = false(size(obj.H_int, 1), 1);
	end
	return
end

if isempty(obj.H_int) && isempty(obj.He_int)
	% still no Hrep available, probably R^n
	sol.H = [];
	sol.He = [];
	sol.I = [];
	return
end

% indices of redundant rows
nold = size(obj.H_int,1); % size of the original system
iredundant_rows = transpose(1:nold);
% fprintf('iredundant_rows-initial\n') 最初有多少个约束
% size(iredundant_rows,1)

if obj.irredundantHRep == false
	% Do redundancy elimination

	% Empty (we cannot do much here, only run to numerical difficulties)

% % % % % % % % % % % % % % % % % % % % % % % % % 这一块是被我注释啦
% 	if obj.isEmptySet
% 		obj.irredundantHRep = true;
% 		sol.H = obj.H_int;
% 		sol.He = obj.He_int;
% 		% logical index set of redundant rows
% 		sol.I = false(size(obj.H_int,1),1);
% 		return
% 	end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    %fprintf('H_int-size\n') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %size(obj.H_int,1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%原始A的维度%%%%%%

	% remove trivially redundant rows with 0*x <= b (note that at this
	% stage we know that the set is not emapy, hence b>=0)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%这里也被我注释掉啦%%%%%%%%%%%
% 	nA = matNorm(obj.H_int(:,1:end-1));
% 	zero_rows = nA < MPTOPTIONS.zero_tol;
% 	if any(zero_rows)
%         %fprintf('zero_rows-remove') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %size(iredundant_rows(zero_rows),1) % redundant的index %%%%%%%%%
% 		iredundant_rows(zero_rows) = []; %删去redundant
% 		obj.H_int(zero_rows, :) = [];
% 
%         %fprintf('iredundant_rows-zero_rows\n')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %size(iredundant_rows,1)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% available heuristics
	% TODO: put these into MPTOPTIONS.modules.geometry.polyhedron.reduce
    start_time = clock;
    
    H = obj.H_int;
    He = obj.He_int;
    
    start_time_box = clock;
	if bounding_box && ~isempty(H)
		% -1 => Redundant
		%  0 => Unknown
		%  1 => Irredundant
		irr = zeros(size(H,1),1);
		
		A = H(:, 1:end-1);
		b = H(:, end);
		size(A,1)
		% Get the bounds from Polyhedron/outerApprox. This has the added
		% value of automatically storing the bounds in obj.Internal.lb/ub,
		% such that we can reuse them later.
		obj.outerApprox;
		lb = obj.Internal.lb;
		ub = obj.Internal.ub;
		
        %%only for unit prediction
%    

		%% Any inequality that contains all the extreme points of the cube is redundant
		val_diff = A * (ub - lb);
        val = (A>0) .* A * (ub - lb) + A * lb - b;
        fprintf('inequality-extreme points-remove') %%%%%%%%%%%%%%%%%%%%%
        extrem_points_num = size(irr( val < -MPTOPTIONS.rel_tol ), 1) %%%%%%%%%%%%%%%%%%%%%%
		irr( val < -MPTOPTIONS.rel_tol ) = -1;
		
		% remove detected redundancies
		irem = (irr==-1);
        index = find(irem);
        num_line_box = sum(index>line_index_start);
        removed_line_index = index(index>line_index_start);
        obj.H_int(removed_line_index,:) = []; % original system
        iredundant_rows(removed_line_index) = []; %index 删去对应的index irem: index_removed

% 		obj.H_int(irem,:) = []; % original system, 不能直接移除load变量的上下界,因为并没有优化load变量的最大最小值.

% 		iredundant_rows(irem) = []; %index 删去对应的index irem: index_removed
        %%irr(irem)     = [];
        screening_time_box = etime(clock, start_time_box);
        fprintf('redundant-extreme points\n');
%         index(1:142)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%冗余约束的索引
       
%         fprintf('iredundant_rows-extreme points\n')
%         size(iredundant_rows,1)%%%%%%%%%%%%%%%%%%%%%%%%%%%剩下约束的数量

    end

%%%%%%%%%%%%%%%%%%%%%%%%%为了比较时间把unique去掉啦%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
% 	H = obj.H_int;
% 	% remove redundances based on uniqueness
% 	[~,i1] = unique(H,'rows');
%     fprintf('unique-removed-rows\n')
% 
%     size(H,1)-size(i1,1)%%%%%%%%%%%%%%%%%%%通过uniqueness去除的约束
%     
% 	si1 = sort(i1);        % we must sort, otherwise we don't respect order of hyperplanes
% 	iredundant_rows = iredundant_rows(si1); %index
%     
%     %fprintf('iredundant_rows-uniqueness\n')
%     %size(iredundant_rows,1) %%%%%%%%%%%unique的约束的数量
%      %obj.H_int = H(si1,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if isempty(He) %%&& ~isempty(x0)
		
		H = obj.H_int;
		A = H(:, 1:end-1);
		b = H(:, end);
		
		nc = size(H,1);
		
		nonredundant=true(nc,1); %并没有找到能丢掉的约束
		removerow=[];
		% ray-shooting找到的是active的 constraints 可以少求解优化问题
		k=1;
		lp.f = [];
		lp.A = A;
		lp.b = b;
		lp.Ae = [];
		lp.be = [];
		lp.lb = [];
		lp.ub = [];
% 		lp.quicklp = true;
		
        fprintf('length(cand)-original way\n')
        length(cand) %总共约束的数量 (被检验区域的, 如果是找critical region的话就是找的region的有效约束)
%         sum(cand) % cand里面等于1的不确定是不是non-redundant
		while k<=length(cand)
			f_cand = find(cand);
			%if any(k==f_cand)
			if ismembc(k, f_cand)
				b(k) = b(k)+0.1;
				lp.f = -A(k,:);
				lp.A = A(nonredundant, :);
				lp.b = b(nonredundant);
				res = mpt_solve(lp);
				%res = mpt_solve(struct('f',-f1,'A',A(nonredundant,:),'b',b(nonredundant)));
				b(k) = b(k)-0.1;
				nonredundant(k) = false;
				if res.exitflag == MPTOPTIONS.OK
					if -lp.f*res.xopt-b(k)>MPTOPTIONS.abs_tol,
						% non-redundant
						nonredundant(k) = true;
					else
						% redundant
						removerow=[removerow k];
					end
				elseif res.exitflag == MPTOPTIONS.UNBOUNDED
					% non-redundant
					nonredundant(k)= true;
				end
			end
			k=k+1;
		end
		
        fprintf('removerow-original\n')
        size(removerow,2) %移除的约束的数量
		iredundant_rows(removerow)=[];
		obj.H_int(removerow,:) = [];

	else
		
		% 更细致的查找, 因为会考虑等式约束, 范围进一步减小
		% for remaining rows test each inequality by solving LP and
		% eliminate rows sequentially
		Ae = obj.He_int(:, 1:end-1);
		be = obj.He_int(:, end);
		
		
		% for remaining rows test each inequality by solving LP and
		% eliminate rows sequentially - this allows better detection of redundant
		% ineqalities as keeping the rows in the next iteration
		

        removed_count = 0;
        remain_limit_number = size(obj.H_int,1);

%       i=1;
% 		while ( i<=size(obj.H_int,1) )
%  			fprintf('i: 被check的constraint的索引')
%              i
% 			A = obj.H_int(:, 1:end-1);
% 			b = obj.H_int(:, end);
% 			
% 			% Solve primal LP
% 			%     min H(i,1:end-1)*x
% 			%   s.t.:  H(~i)*[x;-1] <= 0
% 			%          H(i,1:end-1)*x <= H(i,end)+1
% 			
% 			
% 			H = obj.H_int;
% 			cost = H(i,1:end-1);
% 			offset = H(i,end);
% 			H(i,end) = H(i,end) + 1;
% 			
% 			% Setup data for fast call to LP solver
% 			lpn.f = -cost(:);
% 			
% 			lpn.A = H(:,1:end-1);
% 			lpn.b = H(:,end);
% 			lpn.Ae = Ae; lpn.be = be;
% 			
% 			
%             [~,fval] = linprog(lpn.f,lpn.A,lpn.b,lpn.Ae,lpn.be);
%                 -fval
%                 if (-fval < offset + MPTOPTIONS.abs_tol)
%                     obj.H_int(i,:) = [];
% 					iredundant_rows(i) = [];
%                     removed_count = removed_count+1;
%                 else
%                     i = i+1;
%                 end
% 
%         end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%下面是我自己设计的screening 过滤掉了对decision variables
   
%     iredundant_rows_check = iredundant_rows;
if BT_status
    for i = 1:remain_limit_number
        index_i = iredundant_rows(i);
        if index_i > line_index_start
        fprintf('i: 被check的constraint的索引')
            index_i
            break;
        end
    end
	
    start_time_line = clock;
    while ( i<=size(obj.H_int,1) )
 			fprintf('i: 被check的constraint的索引')
             i
			A = obj.H_int(:, 1:end-1);
			b = obj.H_int(:, end);
			
			% Solve primal LP
			%     min H(i,1:end-1)*x
			%   s.t.:  H(~i)*[x;-1] <= 0
			%          H(i,1:end-1)*x <= H(i,end)+1
			
			
			H = obj.H_int;
			cost = H(i,1:end-1);
			offset = H(i,end);
			H(i,:) = [];
			
			% Setup data for fast call to LP solver
			lpn.f = -cost(:);
			
			lpn.A = H(:,1:end-1);
			lpn.b = H(:,end);
			lpn.Ae = Ae; lpn.be = be;
			
			
            [~,fval] = linprog(lpn.f,lpn.A,lpn.b,lpn.Ae,lpn.be);
                -fval
                if (-fval < offset + MPTOPTIONS.abs_tol+ offset*0.005)
                    obj.H_int(i,:) = [];
					iredundant_rows(i) = [];
                    removed_count = removed_count+1;
                else
                    i = i+1;
                end

        end   
    screening_time_line = etime(clock, start_time_line);
    fprintf('orginal 方法移除的约束数量\n')
    removed_count
end
    end
	obj.irredundantHRep = true;
	% unset obj.optMat since the H-representation might have changed
	obj.optMat = [];
	
end

if isempty(obj.H_int) && isempty(obj.He_int)
	% all rows were removed as redundant to produce R^n
	obj.H_int = [zeros(1, obj.Dim), 1];
	% keep at least one of the original constraints for consistency
	iredundant_rows = 1;
end
sol.H  = obj.H_int;
sol.He = obj.He_int;
sol.I = true(nold,1);
sol.I(iredundant_rows) = false;
screening_time = etime(clock, start_time)
% fprintf('size-iredundant_rows\n') 最后所剩的约束的数量
%size(iredundant_rows,1)
end

