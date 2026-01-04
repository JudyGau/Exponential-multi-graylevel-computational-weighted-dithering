%% 2025/10/12
% Rev 1: 2025/10/12 by Qigao Zhu
% Rev 2: 2025/10/13 by Qigao Zhu

% 不对<0或>1的灰度值进行截断处理，蛇形路径,输入为量化等级和图像
function dithered_img = myDither_v5(levels, img)
% 验证输入
[rows, cols] = size(img);

% 创建高精度工作副本
work_img = img;

% 预计算误差扩散矩阵
weights = [0,    0, 7/16;
    3/16, 5/16, 1/16];

% weights = [0, 0, 0.5;
%     0.25, 0.25, 0];

% 蛇形扫描处理
for i = 1:rows
    % 确定扫描方向
    if mod(i, 2) == 1
        j_range = 1:cols;
        for j = j_range
            % 当前像素值
            old_val = work_img(i, j);

            % 最小误差量化
            [~, idx] = min(abs(old_val - levels));
            % [~, idx] = min(abs(img(i,j)+old_val/img(i,j)-1 - levels));
            new_val = levels(idx);

            % 更新当前像素
            work_img(i, j) = new_val;

            % 计算误差
            err = (old_val - new_val);
            % err = img(i,j)*(img(i,j) - new_val)+old_val-img(i,j);

            % 扩散误差

            if(i==rows)
                if(j<cols)
                    work_img(i, j+1) = work_img(i, j+1) + err;
                else
                    continue;
                end
            else
                if(j==1)
                    work_img(i, j+1) = work_img(i, j+1) + err * weights(1, 3)/(1-weights(2,1));
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2)/(1-weights(2,1));
                    work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 3)/(1-weights(2,1));
                elseif(j==cols)
                    work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 1)/(weights(2,1)+weights(2,2));
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2)/(weights(2,1)+weights(2,2));
                else
                    work_img(i, j+1) = work_img(i, j+1) + err * weights(1, 3);
                    work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 1);
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2);
                    work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 3);
                end
            end

            % if j < cols
            %     work_img(i, j+1) = work_img(i, j+1) + err * weights(1, 3);
            % end
            %
            % if i < rows
            %     if j > 1
            %         work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 1);
            %     else
            %         work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 3)/(1-weights(2,1));
            %         continue;
            %     end
            %
            %     work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2);
            %
            %     if j < cols
            %         work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 3);
            %     else
            %
            %     end
            % end

        end
    else %偶数行，反向扫描
        j_range = cols:-1:1;
        for j = j_range
            % 当前像素值
            old_val = work_img(i, j);

            % 最小误差量化
            [~, idx] = min(abs(old_val - levels));
            new_val = levels(idx);

            % 更新当前像素
            work_img(i, j) = new_val;

            % 计算误差
            err = old_val - new_val;

            % 扩散误差
            if(i==rows)
                if(j>1)
                    work_img(i, j-1) = work_img(i, j-1) + err;
                else
                    continue;
                end
            else
                if(j==cols)
                    work_img(i, j-1) = work_img(i, j-1) + err * weights(1, 3)/(1-weights(2,1));
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2)/(1-weights(2,1));
                    work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 3)/(1-weights(2,1));
                elseif(j==1)
                    work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 1)/(weights(2,1)+weights(2,2));
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2)/(weights(2,1)+weights(2,2));
                else
                    work_img(i, j-1) = work_img(i, j-1) + err * weights(1, 3);
                    work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 1);
                    work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2);
                    work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 3);
                end
            end

            % if j > 1
            %     work_img(i, j-1) = work_img(i, j-1) + err * weights(1, 3);
            % end
            %
            % if i < rows
            %     if j < cols
            %         work_img(i+1, j+1) = work_img(i+1, j+1) + err * weights(2, 1);
            %     else
            %
            %     end
            %     work_img(i+1, j) = work_img(i+1, j) + err * weights(2, 2);
            %     if j >1
            %         work_img(i+1, j-1) = work_img(i+1, j-1) + err * weights(2, 3);
            %     end
            % end

        end
    end


end

dithered_img = work_img;
end