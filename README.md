# Exponential multi-graylevel computational-weighted dithering for high-quality binarized Fourier single-pixel imaging
## simulation_v3_posneg.m   
This is the main simulation program, which can be run directly to perform computer simulation, generate the photoelectric signal intensity matrix IntentityMat.mat, and store it in the folder IntentityMat_v3
## simulationFast_v3_posneg.m 
This is a fast simulation program that requires first running generateMypatterN_PosNeg. m to generate binary Fourier patterns and store them in the folder MyPattern_v3_5_step4_256p. Then, directly read the binary Fourier patterns from the folder MyPattern_v3_5_step4_256p for simulation
## restruction.m
This is an image reconstruction program that reads IntensityMat.mat, outputs the reconstructed image and corresponding spectrogram, as well as SSIM and PSNR at different sampling rates
## GetMyPattern_v3_5_posneg. m and myDither_v5. m
Exponential multi-graylevel computational-weighted dithering

### If you have any questions, please contact zhuqg@mail.ustc.edu.cn



# 高质量二值化傅里叶单像素成像的指数多灰度计算加权抖动
## simulation_v3_posneg.m   
这是仿真主程序，直接运行即可进行计算机仿真, 生成光电信号强度矩阵 IntensityMat.mat 并存放在文件夹 IntensityMat_v3

## simulationFast_v3_posneg.m 
这是快速仿真程序，需要先运行 generateMyPattern_PosNeg.m 生成二值化的傅里叶图案并存储在文件夹MyPattern_v3_5_step4_256p 里面，然后直接从文件夹 MyPattern_v3_5_step4_256p 读取二值化傅里叶图案进行仿真

## restruction.m
这是图像重建程序，读取 IntensityMat.mat ，输出重建的图像和对应的频谱图，以及不同采样率下的SSIM和PSNR

## getMyPattern_v3_5_posneg.m 和 myDither_v5.m
指数多灰阶计算加权抖动算法

### 有疑问请联系 zhuqg@mail.ustc.edu.cn
