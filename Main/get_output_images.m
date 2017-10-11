clear all

sporco_p0 = which('sporco');
sporco_K = strfind(sporco_p0, filesep);
sporco_p1 = sporco_p0(1:sporco_K(end)-1);
sporco_sd = {'.', 'Main', 'DictLearn', 'SparseCode', 'Util'};
for sporco_k=1:length(sporco_sd),
    addpath([sporco_p1 filesep sporco_sd{sporco_k}]);
end
sporco_p2 = genpath([sporco_p1 filesep 'Extrnl']);
addpath(sporco_p2);
sporco_path = sporco_p1;
clear sporco_p0 sporco_p1 sporco_p2 sporco_sd sporco_K sporco_k

% load dict data
load('Data/bg_dict.mat')
load('Data/streak_dict.mat')

% load test data
load('Data/bg.mat')
load('Data/streak.mat')
s0=bg(:,:,5);
s=streak(:,:,5);
%SingleRainImage.jpg
s=single(s);

% Compute representatio
xt=zeros(size(s));
xn=zeros(size(s));
xt=single(xt);
xn=single(xn);
% npd = 16;
% fltlmbd =60;
% [sl_1, sh_1] = lowpass(s(:,:,c), fltlmbd, npd);
%
BilateralParam = 2;
w = 5;
sigma = [3 0.13] * BilateralParam;
% Apply bilateral filter to each image.
sl=[];
sh=[];
residue=[];
xn1=zeros(size(s));


% set channel
CHANNEL=1;
for i=1:10
    residue=s-xt-xn;
    k=mod(i,2);
    
    if k==1
        
        for c=1:CHANNEL
            xn(:,:,c)=xn(:,:,c)+residue(:,:,c);
            D=bg_dict;
            lambda_n=max(0.15-0.05*i,0.01);
            opt_n = [];
            opt_n.Verbose = 10;
            opt_n.MaxMainIter = 20;
            opt_n.rho = 50*lambda_n + 1;
            opt_n.RelStopTol = 1e-3;
            opt_n.AuxVarObj = 0;
            opt_n.HighMemSolve = 1;
            [X, optinf] =cbpdn(D, xn(:,:,c), lambda_n, opt_n);
            DX_c = ifft2(sum(bsxfun(@times, fft2(D, size(X,1), size(X,2)), fft2(X)),3), ...
                'symmetric');
            xn_tv=DX_c;
            [rows cols colors] = size(xn_tv);
            H = fspecial('gaussian', [11,11], 0.8);
            g = imfilter(xn_tv, H, 'circular');
            %g = imnoise(g, 'gaussian', 0, 0.00001);
            % Setup parameters (for example)
            opts.rho_r   = 1;
            opts.beta    = [1 1 0];
            opts.print   = true;
            opts.alpha   = 0.1;
            opts.method  = 'l1';
            
            % Setup mu
            mu           = 1.2;
            xnnnn = deconvtv(g, H, mu, opts);
            xn1(:,:,c)=xnnnn.f;
            
            
        end
    end
    xn=xn1;
    pp=1;
    
    
    if k==0
        
        for c=1:CHANNEL
            xt(:,:,c)=xt(:,:,c)+residue(:,:,c);
            D=streak_dict;
            
            lambda_t=max(3.50-0.19*i,0.10);   
            opt_t = [];
            opt_t.Verbose = 1;
            opt_t.MaxMainIter = 30;
            opt_t.rho = 10*lambda_t + 1;
            opt_t.RelStopTol = 1e-3;
            opt_t.AuxVarObj = 0;
            opt_t.HighMemSolve = 1;
            [X, optinf] = cbpdn_rank(D, xt(:,:,c), lambda_t, opt_t);
            DX_t = ifft2(sum(bsxfun(@times, fft2(D, size(X,1), size(X,2)), fft2(X)),3), ...
                'symmetric');
            
            % Compute reconstruction
            %[sl_t, sh_t] = (lowpass(DX_t, fltlmbd, npd));
            xt(:,:,c)=DX_t;
            
        end
    end
end

subplot(221)
imshow((s0))
title('origin')
colormap(gray)
axis image; axis off;

subplot(222)
imshow(s)
title('input')
colormap(gray)
axis image; axis off;

subplot(223)
imshow(xt,[])
title('bg')
colormap(gray)
axis image; axis off;

subplot(224)
imshow((xn),[])
title('result')
colormap(gray)
axis image; axis off;

% figure;
% imshow(s1)
% colormap(gray)
% axis image; axis off;


streak_psnr=psnr(single(s0),single(s));
fprintf('streak psnr is %f\n',streak_psnr);
streak_mse=mse(single(s0),single(s));
fprintf('streak mse is %f\n',streak_mse);
repaire_psnr=psnr(single(s0),single(abs(xn)));
fprintf('repaire psnr is %f\n',repaire_psnr);
repaire_mse=mse(single(s0),single(xn));
fprintf('repaire mse is %f\n',repaire_mse);
