function [imgavg img_gray ] = tiffavg(imgf,type,varargin)
% create avg/sum/max image from tiff stack
% type=1 --> mean projection
% type=2 --> max projection
% type=3 --> sum projection

temp = length(varargin);
switch temp
    case 0
        calib=0;
    case 1
        posRect = varargin{1};
        calib=1;
end

% extract required metadata
img_info = imfinfo(imgf);
img_length = length(img_info);
img = zeros(img_info(1,1).Width,img_info(1,1).Height,img_length);

% load tiff stack
for i=1:img_length
    img(:,:,i) = imread(imgf,'index',i);
end

% create avg image
switch type
    case 1
        imgavg = mean(img,3);
    case 2
        imgavg = max(img,3);
    case 3
        imgavg = sum(img,3);
end
img_gray = mat2gray(imgavg);


if calib==1
    imgavg = imgavg(posRect(2):posRect(2)+posRect(4),posRect(1):posRect(1)+posRect(3));
    img_gray = img_gray(posRect(2):posRect(2)+posRect(4),posRect(1):posRect(1)+posRect(3));
end

end
