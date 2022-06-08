function [ bit_flip ] = tar_test( Dest )
%tar_test basic test of data processing function
%   just tars the file and returns a value

fileloc = Dest;
folder = ('image_test');

addpath(fileloc);

tarcat = ('_t');
tarfile = strcat(folder, tarcat);


tar(tarfile,folder,fileloc);


bit_flip = True;
end

