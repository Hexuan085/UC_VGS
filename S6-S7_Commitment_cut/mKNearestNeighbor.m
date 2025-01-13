% K-nearest neighbor (10/12/2020)

function KNN = mKNearestNeighbor(feat,label,opts)
% Default 测试不同k对结果的影响
k     = 5; 
kfold = 10;

if isfield(opts,'kfold'), kfold = opts.kfold; end
if isfield(opts,'k'), k = opts.k; end

% Cross-validation
  % [Cross-validation] 
  fold   = cvpartition(label,'KFold',kfold);
  Afold  = zeros(kfold,1); 
  pred2  = [];
  ytest2 = []; 
  for i = 1:kfold
    % Call train & test data
    trainIdx = fold.training(i); testIdx = fold.test(i);
    xtrain   = feat(trainIdx,:); ytrain  = label(trainIdx);
    xtest    = feat(testIdx,:);  ytest   = label(testIdx);
    % Train model
    My_Model = fitcknn(xtrain,ytrain,'NumNeighbors',k);
    % Test 
    pred = predict(My_Model,xtest);
    % Accuracy
    Afold(i) = sum(pred == ytest) / length(ytest);
    
    if i == 1
        KNN.mymodel = My_Model;
    end

    if i>1 && Afold(i)-Afold(i-1)>0
    KNN.mymodel = My_Model;
    end

    clear My_Model
    % Store temporary
    pred2  = [pred2(1:end); pred]; 
    ytest2 = [ytest2(1:end); ytest];
  end
  
% Confusion matrix
confmat = confusionmat(ytest2,pred2);
% Overall accuracy
acc = mean(Afold);
% Store
KNN.acc  = acc;
KNN.con  = confmat;

fprintf('\n Accuracy (KNN-CV): %g %%',100 * acc);

end
