fileloc = ('C:\Users\cioleary\Desktop\Test_Transfer');
folder = ('2017-07-24_12-06-24');
%folder = ('List12');

addpath(fileloc);


zipcat = ('_z');
tarcat = ('_t');

zipfile = strcat(folder,zipcat);
tarfile = strcat(folder, tarcat);

tic
tar(tarfile,folder,fileloc);
toc

tic
zip(zipfile,folder,fileloc);
toc
