function specshow(spec)
	imagesc(mat2gray((log(abs(spec)+1).^(1/3)))); 
    % axis image; 
    axis off;
    colormap jet; 
end