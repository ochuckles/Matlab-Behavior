%% Automatically Preprocess images from Flickr Pics folder
% ***Should only run if get_Flickr_Seth is done running.***
% Resize images

% assumes no .mat files in the folder
% resizes images to desired size using imresize
clear, clc

imageX = 64;% desired horizontal image size
imageY = 64;% desired vertical image size

imgdir = '\\research.wanprc.org\Research\Buffalo Lab\eblab\Cortex Programs\DMS PS Yassa\Images\Novel Randomized';
resized_dir = [imgdir '64x64\'];
mkdir(resized_dir);

cd(imgdir)
a = ls;
for aa = 1:100%size(a,1);
    if ~isempty(strfind(a(aa,:),'bmp')) || ~isempty(strfind(a(aa,:),'jpg')) || ~isempty(strfind(a(aa,:),'png'))...
            ||  ~isempty(strfind(a(aa,:),'jpeg'))
        img = imread(a(aa,:));
        if all(size(img) == [imageY,imageX,3]);
            imwrite(img,[resized_dir a(aa,1:end-4) '.bmp'],'bmp');
            delete([imgdir a(aa,:)]);
        else
            img = imresize(img,[imageY,imageX]);
            imwrite(img,[resized_dir a(aa,1:end-4) '.bmp'],'bmp');
            delete([imgdir a(aa,:)]);
        end
    end
end