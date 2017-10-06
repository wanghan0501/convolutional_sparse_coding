%% get convolutional low-rank coding dictionary

clear
close all
load('Data/data_200.mat')

%dic_atoms=20;
%D0 = zeros(16,16,dic_atoms);
%D0(3:15,3:15,:) = randn(13,13,dic_atoms);

% Construct initial dictionary
D0 = zeros(8,8,32, 'single');
D0(3:6,3:6,:) = single(randn(4,4,32));

% get traning images
train_img=streak-bg;
train_img=train_img(:,:,10:150);

% Set up cbpdndl parameters
lambda = 0.01;
opt = [];
opt.Verbose = 1;
opt.MaxMainIter =50;
opt.rho =40*lambda;
opt.sigma = size(train_img,3);
opt.AutoRho = 1;
opt.AutoRhoPeriod = 10;
opt.AutoSigma = 1;
opt.AutoSigmaPeriod = 10;
opt.XRelaxParam = 1.8;
opt.DRelaxParam = 1.8;


% Do dictionary learning
[D, X, optinf] = cbpdndl_rank(D0,train_img,lambda,opt);


for p=1:20
    z=2;
    figure(1);
    subplot(2,2,1)
    imagesc(sum(abs(X(:,:,p,z)),3));
    title('Sum of absolute value of coefficient maps');
    axis off; axis image;
    subplot(2,2,2)
    imagesc(train_img(:,:,z));
    title('Sum of absolute value of coefficient maps');
    axis off; axis image;
    
    pause(0.3);
end


% Display learned dictionary
figure;
imdisp(tiledict(D));

% save
streak_dict = D;
save('Data/streak_dict.mat','streak_dict');