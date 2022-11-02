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
        Mask_pharynx=imread(strcat(path,'Mask-pharynx\',listfile(file).name));
        ImageData=imread(strcat(path,Channel,'\',listfile(file).name));
        RawData(:,:,ch)=imread(strcat(path,Channel,'\',listfile(file).name));

        SumInt(ch)=sum(ImageData((MaskData==0)));
        MeanInt(ch)=mean(ImageData((MaskData==0)));

        SumInt_pharynx(ch)=sum(ImageData((Mask_pharynx==0)));
        MeanInt_pharynx(ch)=mean(ImageData((Mask_pharynx==0)));


        % % %         find head
        for i=1:size(Mask_pharynx,2)
            if find(Mask_pharynx(:,i)==0)
                MinIndex=i;
                break
            end
        end
        if MinIndex>size(MaskData,2)/2
            MaskData=fliplr(MaskData);
            Mask_pharynx=fliplr(Mask_pharynx);
            ImageData=fliplr(ImageData);
            RawData=fliplr(RawData);
             % % %         find head again
            for i=1:size(MaskData,2)
                if find(MaskData(:,i)==0)
                    MinIndex=i;
                    break
                end
            end
        end
        % % %         find rear of pharynx
        for i=1:size(Mask_pharynx,2)
            if find(Mask_pharynx(:,i)==0)
                MaxIndex_pharynx=i;
            end
        end
        % % %         find rear
        for i=MinIndex:size(MaskData,2)
            if find(MaskData(:,i)==0)
                MaxIndex=i;
            end
        end

        Section1=[MaxIndex_pharynx                                          :1: MaxIndex_pharynx+round((MaxIndex-MaxIndex_pharynx)/3)];
        Section2=[MaxIndex_pharynx+round((MaxIndex-MaxIndex_pharynx)/3)     :1: MaxIndex_pharynx+round((MaxIndex-MaxIndex_pharynx)*2/3)];
        Section3=[MaxIndex_pharynx+round((MaxIndex-MaxIndex_pharynx)*2/3)   :1: MaxIndex];
        

        Mask_keep=MaskData(:,Section1);
        im_keep=ImageData(:,Section1);
        SumInt_section1(ch)=sum(im_keep((Mask_keep==0)));
        MeanInt_section1(ch)=mean(im_keep((Mask_keep==0)),"all");
        clear Mask_keep im_keep

        Mask_keep=MaskData(:,Section2);
        im_keep=ImageData(:,Section2);
        SumInt_section2(ch)=sum(ImageData((Mask_keep==0)));
        MeanInt_section2(ch)=mean(im_keep((Mask_keep==0)),"all");
        clear Mask_keep im_keep

        Mask_keep=MaskData(:,Section3);
        im_keep=ImageData(:,Section3);
        SumInt_section3(ch)=sum(ImageData((Mask_keep==0)));
        MeanInt_section3(ch)=mean(im_keep((Mask_keep==0)),"all");
        clear Mask_keep im_keep


        IntensityPercent=[SumInt_pharynx,SumInt_section1, SumInt_section2, SumInt_section3]/SumInt;
    end
    save(strcat(path,'ResultInSeparate-',RawName,'.mat'));
end
