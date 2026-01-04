%% 2025/10/12
% Rev 1: 2025/10/12 by Qigao Zhu
% Rev 2: 2025/10/13 by Qigao Zhu

% 像素值<0或>1时不进行数值截断+蛇形路径,自适应的边缘误差扩散权重
function [totalPattern,bit_planes] = getMyPattern_v3_5_posneg(n, img)

num_levels = 2*2^n-1;
levels = linspace(0, 1, num_levels);

img=myDither_v5(levels,img);

%将图案的灰度值线性变换到[-1,1]
img=(img-0.5)*2;

%取大于0的部分
img=max(0,img);

totalPattern=img;

% 获取图像尺寸
[rows, cols] = size(img);

% 转换为整数
max_val = 2^n - 1;
int_img = round(img * max_val);

% 预分配三维逻辑数组
bit_planes = false(rows, cols, n);

% 提取每个位平面
for bit = n:-1:1
    % 计算当前位的掩码 (从最高位开始)
    mask = bitshift(1, bit-1);

    % 提取位平面
    plane = bitand(int_img, mask);

    % 转换为逻辑值并存储到三维数组
    bit_planes(:, :, n-bit+1) = logical(plane);

end
end