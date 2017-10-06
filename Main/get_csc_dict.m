%% traing images to get the dictionary of background images

clc;
clear;

% load data images
load ('Data/data_200.mat')

% Training images
S0 = bg(:,:,1:5);

% Filter input images and compute highpass images
npd = 16;
fltlmbd = 5;
[Sl, Sh] = lowpass(S0, fltlmbd, npd);

% Construct initial dictionary
D0 = zeros(8,8,32, 'single');
D0(3:6,3:6,:) = single(randn(4,4,32));


% Set up cbpdndl parameters
lambda = 0.2;
opt = [];
opt.Verbose = 1;
opt.MaxMainIter = 1000;
opt.rho = 50*lambda + 0.5;
opt.sigma = size(Sh,3);
opt.AutoRho = 1;
opt.AutoRhoPeriod = 10;
opt.AutoSigma = 1;
opt.AutoSigmaPeriod = 10;
opt.XRelaxParam = 1.8;
opt.DRelaxParam = 1.8;

% Do dictionary learning
[D, X, optinf] = cbpdndl(D0, Sh, lambda, opt);


% Display learned dictionary
figure;
imdisp(tiledict(D));

% Save dictionary
bg_dict = D;
save('Data/bg_dict.mat','bg_dict');

% Plot functional value evolution
figure;
plot(optinf.itstat(:,2));
xlabel('Iterations');
ylabel('Functional value');
