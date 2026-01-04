
%% 2025/10/12
% Rev 1: 2025/10/12 by Qigao Zhu
% Rev 2: 2025/10/13 by Qigao Zhu

%% simulating single-pixel imaging with phase-shifting sinusoid illumination
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
% [imgFile pathname] = uigetfile({'*.bmp;*.jpg;*.tif;*.png;*.gif'','...
%     'All Image Files';'*.*','All Files'});
% InputImg = im2double(imread([pathname imgFile]));
% figure,imshow(InputImg);title('Input image'); axis image;

%傅里叶图案参数，宽和高
mRowScale=256;
nColScale=256;
%参数，量化等级
n=2;

mRow = mRowScale / scale;
nCol = nColScale / scale;

fxArr = [0:1:nCol-1]/nCol;
fyArr = [0:1:mRow-1]/mRow;

[fxMat, fyMat] = meshgrid(fxArr, fyArr);           % generate coordinates in Fourier domain (not neccessary)
fxMat = fftshift(fxMat);
fyMat = fftshift(fyMat);

OrderMat = getOrderMat(mRow, nCol, SamplingPath);                              % generate sampling path in Fourier domain
[nCoeft,~] = size(OrderMat);
nCoeft = round(nCoeft * SpectralCoverage);

InitPhaseArr = getInitPhaseArr(nStepPS, Phaseshift);
IntensityMat = zeros(mRow, nCol, nStepPS);

RealFourierCoeftList = getRealFourierCoeftList(mRow, nCol);

imgNumber=0;

h = waitbar(0, '请稍候...'); % 创建进度条

tic;

for iCoeft =1:nCoeft
    iRow = OrderMat(iCoeft,1);
    jCol = OrderMat(iCoeft,2);

    fx = fxMat(iRow,jCol);
    fy = fyMat(iRow,jCol);

    IsRealCoeft = existVectorInMat( [iRow jCol], RealFourierCoeftList );

    for iStep = 1:nStepPS
        if IsRealCoeft == 1 && iStep > 2
            if nStepPS == 3
                IntensityMat(iRow,jCol,iStep) = IntensityMat(iRow,jCol,2);
            end
            if nStepPS == 4
                IntensityMat(iRow,jCol,iStep) = 0;
            end
            continue;
        end

        Pattern  = getFourierPattern( Amplitude, mRow, nCol, fx, fy, InitPhaseArr(iStep) );
        Pattern  = imresize(Pattern, scale, 'bicubic');
        % figure, imshow(Pattern);
        

        [~,patterns] = getMyPattern_v3_5_posneg(n,Pattern);
        % figure, imshow(myPattern);

        for k=1:n
            % figure, imshow(patterns(:,:,k));title(['subPattern',num2str(k)]);
            imgNumber=imgNumber+1;
            % 保存为BMP文件
            imwrite(patterns(:,:,k), ['./MyPattern_v3_5_step4_256p/',num2str(imgNumber),'.bmp']);

        end


    end

    progress = iCoeft/(mRowScale*nColScale/2*SpectralCoverage);
    waitbar(progress, h, sprintf('已完成: %f%%', progress*100));
end

toc;


