%% 2025/10/12
% Rev 1: 2025/10/12 by Qigao Zhu
% Rev 2: 2025/12/13 by Qigao Zhu

close all
clear all
clc
%% Parameters
nStepPS = 4;
Phaseshift = 360/nStepPS;
scale = 1;
Amplitude = 1;
% SpectralCoverage = 1;
SamplingPath = 'circular';
%n=14; %傅里叶子掩膜图案的个数

% Get input image
[imgFile, pathname] = uigetfile({'*.bmp;*.jpg;*.tif;*.png;*.gif'','...
    'All Image Files';'*.*','All Files'});
% [~, nameWithoutExt, ~] = fileparts(imgFile);
InputImg = im2double(imread([pathname imgFile]));
% 检查通道数
if size(InputImg, 3) == 3
    % 提取第一个通道（R通道）作为灰度图
    InputImg = InputImg(:, :, 1);
end
figure,imshow(InputImg);title('Input image'); axis image;

[mRowScale, nColScale] = size(InputImg);

mRow = mRowScale / scale;
nCol = nColScale / scale;

% OrderMat = load("grayCitygateOrderMat_256_256.mat").coordinates;                             % generate sampling path in Fourier domain

snrVal = zeros(20,1);
psnrVal = zeros(20,1);
ssimVal = zeros(20,1);
rmseVal = zeros(20,1);

tic;


[filename, pathName]  = uigetfile('*.mat', '选择MAT文件');

[~, nameWithoutExt, ~] = fileparts(filename);
% 构建完整文件路径
filename = fullfile(pathName, filename);


if exist(filename, 'file')
    dataStruct=load(filename);
    tempMat=dataStruct.IntensityMat2;
    disp('The path matrix exists.');
end

for SpectralCoverage = 0.05:0.05:1

    disp(["SpectralCoverage=",num2str(SpectralCoverage)])
    OrderMat = getOrderMat(mRow, nCol, SamplingPath,SpectralCoverage);  
    [nCoeft,tmp] = size(OrderMat);
    nCoeft = round(nCoeft * SpectralCoverage);
    IntensityMat = zeros(mRow, nCol, nStepPS);

    for iCoeft = 1:nCoeft
        iRow = OrderMat(iCoeft,1);
        jCol = OrderMat(iCoeft,2);
        IntensityMat(iRow,jCol,:)=tempMat(iRow,jCol,:);
    end

    [img, spec] = getFSPIReconstruction( IntensityMat, nStepPS, Phaseshift );
    img  = imresize(img, scale, 'bicubic');
    % img(img<0)=0;
    % img=(img-min(img(:)))/(max(img(:))-min(img(:)));

    % figure, imshow(img); title('Reconstructed Img'); 
    % figure, specshow(spec);
    % save(['./Spec/',nameWithoutExt,'_',num2str(SpectralCoverage),'_spec.mat'],'spec');

    snrVal(round(SpectralCoverage*20))=image_snr(InputImg,img);
    psnrVal(round(SpectralCoverage*20))=psnr(img, InputImg);
    ssimVal(round(SpectralCoverage*20)) = ssim(img, InputImg);
    rmseVal(round(SpectralCoverage*20)) = rmse(img, InputImg);
    disp(['SSIM = ', num2str(ssimVal(round(SpectralCoverage*20)))]);
    disp(['RMSE = ', num2str(rmseVal(round(SpectralCoverage*20)))]);
    disp(['SNR = ', num2str(snrVal(round(SpectralCoverage*20))), ' dB']);
    disp(['PSNR = ', num2str(psnrVal(round(SpectralCoverage*20))), ' dB']);

end
figure, imshow(img);
figure, specshow(spec);
save(['./Spec/',nameWithoutExt,'_',num2str(SpectralCoverage),'_spec.mat'],'spec');

imwrite(img,['./RecoveryImage_simu/',nameWithoutExt,'.bmp']);
imageQuality=[ssimVal,psnrVal];
save(['./RecoveryImage_simu/',nameWithoutExt,'.mat'],'imageQuality');


