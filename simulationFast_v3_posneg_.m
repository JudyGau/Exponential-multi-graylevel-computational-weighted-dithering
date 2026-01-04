%% 2025/10/12
% Rev 1: 2025/10/12 by Qigao Zhu
% Rev 2: 2025/10/13 by Qigao Zhu

%% simulating binarized Fourier single-pixel imaging with Exponential multi-graylevel computational-weighted dithering
close all
clear all
clc

%% Parameters
nStepPS = 4;
Phaseshift = 360/nStepPS;
scale = 1;
Amplitude = 1;
SpectralCoverage = 1;
SamplingPath = 'circular';


% Get input image
[imgFile, pathname] = uigetfile({'*.bmp;*.jpg;*.tif;*.png;*.gif'','...
    'All Image Files';'*.*','All Files'});
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

fxArr = [0:1:nCol-1]/nCol;
fyArr = [0:1:mRow-1]/mRow;

[fxMat, fyMat] = meshgrid(fxArr, fyArr);           % generate coordinates in Fourier domain (not neccessary)
fxMat = fftshift(fxMat);
fyMat = fftshift(fyMat);

OrderMat = getOrderMat(mRow, nCol, SamplingPath);                              % generate sampling path in Fourier domain
% [nCoeft,tmp] = size(OrderMat);
% nCoeft = round(nCoeft * SpectralCoverage);

InitPhaseArr = getInitPhaseArr(nStepPS, Phaseshift);
RealFourierCoeftList = getRealFourierCoeftList(mRow, nCol);

tic;

disp(["SpectralCoverage=",SpectralCoverage])
[nCoeft,tmp] = size(OrderMat);
nCoeft = round(nCoeft * SpectralCoverage);

% IntensityMat1 = zeros(mRow, nCol, nStepPS);
IntensityMat2 = zeros(mRow, nCol, nStepPS);

dirName = uigetdir();
if exist(dirName, 'dir')
    disp([dirName,'The dir exists.']);
end

n=2;
imgNumber=0;

h = waitbar(0, '请稍候...'); % 创建进度条

for iCoeft = 1:nCoeft
    iRow = OrderMat(iCoeft,1);
    jCol = OrderMat(iCoeft,2);

    fx = fxMat(iRow,jCol);
    fy = fyMat(iRow,jCol);

    IsRealCoeft = existVectorInMat( [iRow jCol], RealFourierCoeftList );

    for iStep = 1:nStepPS
        if IsRealCoeft == 1 && iStep > 2
            if nStepPS == 3
                % IntensityMat1(iRow,jCol,iStep) = IntensityMat1(iRow,jCol,2);
                IntensityMat2(iRow,jCol,iStep) = IntensityMat2(iRow,jCol,2);
                %IntensityMat3(iRow,jCol,iStep) = IntensityMat3(iRow,jCol,2);
            end
            if nStepPS == 4
                % IntensityMat1(iRow,jCol,iStep) = 0;
                IntensityMat2(iRow,jCol,iStep) = 0;
                %IntensityMat3(iRow,jCol,iStep) = 0;
            end
            continue;
        end
    
        
        ditherPattern=zeros(mRow,nCol);
        for k=n:-1:1
            % figure, imshow(patterns(:,:,k));title(['subPattern',num2str(k)]);
            imgNumber=imgNumber+1;
            ditherPattern = ditherPattern + (imread([dirName,'/',num2str(imgNumber),'.bmp']))*2^(k-1)/(2^n-1); 
        end

        IntensityMat2(iRow,jCol,iStep) = sum(sum( ditherPattern .* InputImg ));

    end

    progress = iCoeft/(mRowScale*nColScale/2*SpectralCoverage);
    waitbar(progress, h, sprintf('已完成: %f%%', progress*100));
end

toc;


[~, nameWithoutExt, ~] = fileparts(imgFile);
save(['./IntensityMat_v3/',nameWithoutExt,'_',num2str(n),'IntensityMat_v3_5_posneg.mat'],'IntensityMat2')
[img2, spec2] = getFSPIReconstruction( IntensityMat2, nStepPS, Phaseshift );
img2  = imresize(img2, scale, 'bicubic');

% img2=(img2-min(img2(:)))/(max(img2(:))-min(img2(:)));

figure, imshow(img2); title('Reconstructed Img');
figure, specshow(spec2);
snr=image_snr(InputImg,img2);
psnrVal=psnr(img2, InputImg);
ssimval = ssim(img2, InputImg);
rmseVal= rmse(img2,InputImg);
disp(['SSIM = ', num2str(ssimval)]);
disp(['RMSE = ', num2str(rmseVal)]);
disp(['SNR = ', num2str(snr), ' dB']);
disp(['PSNR = ', num2str(psnrVal), ' dB']);







