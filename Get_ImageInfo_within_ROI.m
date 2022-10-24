clear
close all


addpath(pwd);
[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
listfile=dir(strcat(path,'00*.tif'));
cd (path)
tiff_info_first = imfinfo(listfile(1).name);


d = dir('ch*');
list_ui = {d.name};
[indx,tf]=listdlg('ListString',list_ui);

for file=1:size(listfile,1)
    [~,RawName,~] = fileparts(listfile(file).name);
    tiff_info = imfinfo(listfile(file).name);
    disp(RawName);

    MaskData=zeros(tiff_info(1).Height,tiff_info(1).Width);
    ImageData=zeros(tiff_info(1).Height,tiff_info(1).Width);
    RawData=zeros(tiff_info(1).Height,tiff_info(1).Width,size(indx,2));
    SumInt=zeros(1,size(indx,2)); MeanInt=zeros(1,size(indx,2));

    for ch=1:size(indx,2)
        Channel=list_ui{indx(ch)};
        MaskData=imread(strcat(path,'Mask\',listfile(file).name));
        ImageData=imread(strcat(path,Channel,'\',listfile(file).name));
        RawData(:,:,ch)=imread(strcat(path,Channel,'\',listfile(file).name));
        
        SumInt(ch)=sum(ImageData((MaskData==0)));
        MeanInt(ch)=mean(ImageData((MaskData==0)));

    end
    save(strcat(path,'ResultInRoi-',RawName,'.mat'));
end
