num_train_sample = 500; % default 5000
num_test_sample = 100; % default 1000

%初始化输入的x和验证集
feat = input(1:num_train_sample,1:num_buses);
xtest = input(num_train_sample+1:num_train_sample+num_test_sample,1:num_buses);
ytest = input(num_train_sample+1:num_train_sample+num_test_sample,num_buses+1:num_buses+num_of_gen);


%%用来记录常开,常闭,待定unit的index
unit_status = input(1:num_train_sample,num_buses+1:num_buses+num_of_gen);
unit_status_check = sum(input(1:num_train_sample,num_buses+1:num_buses+num_of_gen));
unit_index_0 = find(unit_status_check==0);
unit_index_1 = find(unit_status_check==num_train_sample);
unit_index = 1:num_of_gen;
unit_index([unit_index_0,unit_index_1]) = [];

%用来记录accuracy和prediction
accuracy_total = [];
pred_unit_total = [];
accuracy_off = [];
accuracy_on = [];

%初始化prediction和准确率
pred_unit_total = ones(num_test_sample,num_of_gen);
accuracy_total = zeros(num_of_gen,1);
accuracy_unknown_total = zeros(1, size(unit_index',2));

%%设置KNN model
opts.kfold = 10;
opts.k = 3;
stable_cound = 5; %重复训练

%训练模型
for j = 1:stable_cound
accuracy_unknown = [];

for i= 1:size(unit_index')

label = unit_status(:,unit_index(i));

KNN = mKNearestNeighbor(feat,label,opts);

model_unit{i} = KNN.mymodel;    

accuracy_unknown = [accuracy_unknown, KNN.acc];
    
end
accuracy_unknown_total = accuracy_unknown_total + accuracy_unknown;
end

accuracy_unknown_total = accuracy_unknown_total/stable_cound

% 判断能够用KNN的unit, 并用KNN预测 (重复stable_cound次训练, 准确率均值在0.9998以上的采用)
% 不用最低准确率来筛选是因为容易波动
for i = 1:size(unit_index')
    
    accuracy_total(unit_index(i))=accuracy_unknown_total(i);
    pred_unit = predict(model_unit{i},xtest);
    accuracy = 1-sum(abs(pred_unit - ytest(:,unit_index(i))))/num_test_sample
    
    if round(accuracy_unknown_total(i),4) < 0.9995 || accuracy<1
    pred_unit_total(:,unit_index(i)) = -1;
    else
    pred_unit_total(:,unit_index(i)) = pred_unit;
    end

end

%常闭unit
if size(unit_index_0)>0
for i = 1:size(unit_index_0')

    label = ytest(:,unit_index_0(i));
    accuracy = 1-sum((0 - label))/num_test_sample;
    accuracy_off = [accuracy_off, accuracy];
    accuracy_total(unit_index_0(i)) = accuracy;
    pred_unit_total(:,unit_index_0(i)) = 0;
end
end

%常开unit
if size(unit_index_1)>0
for i = 1:size(unit_index_1')

    label = ytest(:,unit_index_1(i));
    accuracy = 1-sum(1 - label)/num_test_sample;
    accuracy_on = [accuracy_on, accuracy];
    accuracy_total(unit_index_1(i)) = accuracy;
    pred_unit_total(:,unit_index_1(i)) = 1;
end
end
