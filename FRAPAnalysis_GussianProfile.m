clear
close all



[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
listfile=dir(strcat(path,'00*.tif'));
cd (path)

prompt = {'Frame interval (s):','Prebleach frames:','Right after bleach frame:','Fit start frame:','Pixel size (pix/um)'};
dlgtitle = 'Input';
dims = [1 35];  
definput = {'0.0884','2','3','3','4.0111'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
Interval=str2double(answer{1});
PreBleachFrame=str2num(answer{2});
RightAfterBleachframe=str2num(answer{3});
FitRange_start=str2num(answer{4});  
pix_size=str2double(answer{5});  

% for file=1:size(listfile,1)
file=1;
Num_frame=60;
inputimage=listfile(file).name;
tiff_info = imfinfo(inputimage);
for i=1:Num_frame
imData(:,:,i) = imread(inputimage, i);
end

imData_d=double(imData);
pre_imData=imData_d(:,:,1:PreBleachFrame);
im_fit_Data=imData_d(:,:,RightAfterBleachframe:size(imData_d,3))...
    ./ mean(pre_imData,3);



[folder name ext]=fileparts(inputimage);
inputFRAPdata=strcat(folder,"\",name,".txt");
FRAPData=readmatrix(inputFRAPdata,NumHeaderLines=1);
w=sqrt(FRAPData(1,2)/pi);
center=round(FRAPData(1,7:8)*pix_size);
imagesc(im_fit_Data(:,:,1))
hold on
scatter(center(1,1),center(1,2),'ok')
hold off

Fit_initial_Para=func_leastsquare_with_GaussianDist_determineInitialPara(im_fit_Data(:,:,1),center);
RegressionDist=zeros(size(im_fit_Data,1),size(im_fit_Data,2),size(im_fit_Data,3));
for k=1:1
    for j=1:size(im_fit_Data,1)
        for i=1:size(im_fit_Data,2)
            R= sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                    + (j-center(1,2))*(j-center(1,2) ) );
            t=Interval*(k-1);
            RegressionDist(j,i,k)=func_C(Fit_initial_Para,R,t,0);
        end
    end
end

clims=[0 1];
imagesc(im_fit_Data(:,:,1),clims)
hold on
scatter(center(1,1),center(1,2),'MarkerFaceColor','k')
hold off

imagesc(RegressionDist(:,:,1),clims)
hold on
scatter(center(1,1),center(1,2),'MarkerFaceColor','k')
hold off


FitPara=...
func_leastsquare_with_GaussianDist(im_fit_Data(:,:,:),center,Fit_initial_Para,Interval);
DiffCoef=FitPara/pix_size;

for k=1:size(im_fit_Data,3)
    for j=1:size(im_fit_Data,1)
        for i=1:size(im_fit_Data,2)
            R= sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                    + (j-center(1,2))*(j-center(1,2) ) );
            t=Interval*(k-1);
            RegressionDist(j,i,k)=func_C(Fit_initial_Para,R,t,FitPara);
        end
    end
end
% imagesc(RegressionDist(:,:,20),clims)
sliceViewer(RegressionDist);
colormap ('jet');
sliceViewer(im_fit_Data);
colormap ('jet');
disp(DiffCoef);




% plot(FRAPData(:,1)*Interval,FRAPData(:,3))

% sz=size(FRAPData);
% I1=mean(FRAPData(1:PreBleachFrame ,3) );
% I0=FRAPData(RightAfterBleachframe ,3);
% t=( FRAPData(RightAfterBleachframe+FitRange_start-1:size(tiff_info, 1), 1) - RightAfterBleachframe ) *Interval;
% y=  FRAPData(RightAfterBleachframe+FitRange_start-1:size(tiff_info, 1), 3)./I1;
% K0=-log(y(1));
% % Leastsquare_bessel
% FitPara=func_leastsquare_with_uniformdiscmodel(y,t,w,K0);
% disp(FitPara)
% 
% 
% % % % Output FRAP curve
% F=zeros(size(t,1),1);
% for i=1:size(t,1)
%     F(i,1)=func_bessel(FitPara,t(i),w,K0);
% end
% 
% p=plot( (FRAPData(:,1)-PreBleachFrame) * Interval, FRAPData(:,3) ./ I1,'*');
% hold on
% % F = @(x,xdata) 1.0+ ( exp(-x(1))-1.0 )    ...
% %     .* ( 1.0 - exp(-(w*w)/(2.0.*x(2).*t))     ...
% %     .* ( besselj( 0,(w*w./(2.0.*x(2).*t) ) ) + besselj( 1,(w*w./(2.0.*x(2).*t) ) ) )   );
% 
% plot(t,F,'-k' )
% hold off
% outname=strcat(pwd,'\uniformdisc_',name,'.mat');
% save(outname);
% xlabel('Time \itt\rm (s)')
% ylabel('Intensity')
% ax=gca;
% ax.FontSize=20;
% ax.FontName='Arial';
% 

%%%check tif file
% figure
% colormap ('jet')
% tiff_info = imfinfo(inputimage); % return tiff structure, one element per image
% tiff_stack = imread(inputimage, 1) ; % read in first image
% %concatenate each successive tiff to tiff_stack
% for ii = 2 : size(tiff_info, 1)
%     temp_tiff = imread(inputimage, ii);
%     tiff_stack = cat(3 , tiff_stack, temp_tiff);
% end


% end

function f=func_bessel(para,time,w,K0)
if time==0
    time=1E-20;
end
f=1.0+ ( exp(-K0)-1.0 )    ...
    * ( 1.0 - exp(-(w*w)/(2.0*para(1)*time))     ...
    * ( besselj( 0,(w*w/(2.0*para(1)*time) ) ) + besselj( 1,(w*w/(2.0*para(1)*time) ) ) )   );
end

function F_=func_C(para_ini,r,t,D)
F_= para_ini(1)-para_ini(2)/(para_ini(3)+4.0*D*t)...
    *exp( -r*r/(para_ini(3) + +4.0*D*t) );
end
