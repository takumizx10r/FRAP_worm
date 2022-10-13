clear
close all



[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
listfile=dir(strcat(path,'00*.tif'));
cd (path)

prompt = {'Frame interval (s):','Prebleach frames:','Right after bleach frame:','Fit range:'};
dlgtitle = 'Input';
dims = [1 35];  
definput = {'0.0884','2','3','inf'};
answer = inputdlg(prompt,dlgtitle,dims,definput)
Interval=str2double(answer{1});
PreBleachFrame=str2num(answer{2});
RightAfterBleachframe=str2num(answer{3});
FitRange=str2num(answer{4});  

for file=1:size(listfile,1)
inputimage=listfile(file).name;
tiff_info = imfinfo(inputimage);
  

if FitRange>size(tiff_info, 1)
    FitRange=size(tiff_info, 1);
end

[folder name ext]=fileparts(inputimage);
inputFRAPdata=strcat(folder,"\",name,".txt");
FRAPData=readmatrix(inputFRAPdata,NumHeaderLines=1);
w=sqrt(FRAPData(1,2)/pi);
plot(FRAPData(:,1)*Interval,FRAPData(:,3))

sz=size(FRAPData);
I1=mean(FRAPData(1:PreBleachFrame ,3) );
I0=FRAPData(RightAfterBleachframe ,3);
t=( FRAPData(RightAfterBleachframe:FitRange, 1) - RightAfterBleachframe ) *Interval;
y=  FRAPData(RightAfterBleachframe:FitRange, 3)./I1;
K0=-log(y(1));
% Leastsquare_bessel
FitPara=func_leastsquare_with_uniformdiscmodel(y,t,w,K0);
disp(FitPara)


% % % Output FRAP curve
F=zeros(size(t,1),1);
for i=1:size(t,1)
    F(i,1)=func_bessel(FitPara,t(i),w,K0);
end

p=plot( (FRAPData(:,1)-PreBleachFrame) * Interval, FRAPData(:,3) ./ I1,'*');
hold on
% F = @(x,xdata) 1.0+ ( exp(-x(1))-1.0 )    ...
%     .* ( 1.0 - exp(-(w*w)/(2.0.*x(2).*t))     ...
%     .* ( besselj( 0,(w*w./(2.0.*x(2).*t) ) ) + besselj( 1,(w*w./(2.0.*x(2).*t) ) ) )   );

plot(t,F,'-k' )
hold off
outname=strcat(pwd,'\uniformdisc_',name,'.mat');
save(outname);
xlabel('Time \itt\rm (s)')
ylabel('Intensity')
ax=gca;
ax.FontSize=20;
ax.FontName='Arial';


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
% sliceViewer(tiff_stack);
% colormap ('jet');

end

function f=func_bessel(para,time,w,K0)
if time==0
    time=1E-20;
end
f=1.0+ ( exp(-K0)-1.0 )    ...
    * ( 1.0 - exp(-(w*w)/(2.0*para(1)*time))     ...
    * ( besselj( 0,(w*w/(2.0*para(1)*time) ) ) + besselj( 1,(w*w/(2.0*para(1)*time) ) ) )   );
end
