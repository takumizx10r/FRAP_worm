clear 
close all
% Interval=0.07970; %(sec)
Interval=0.145; %(sec)
PreBleachFrame=2;
RightAfterBleachframe=3;
FitRange=30;



[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
cd (path)
tiff_info = imfinfo(inputimage);
if FitRange>size(tiff_info, 1)
    FitRange=size(tiff_info, 1);
end

[folder name ext]=fileparts(inputimage);
inputFRAPdata=strcat(folder,"\",name,".txt");
FRAPData=readmatrix(inputFRAPdata,NumHeaderLines=1);

plot(FRAPData(:,1)*Interval,FRAPData(:,3))

sz=size(FRAPData);
I1=mean(FRAPData(1:PreBleachFrame ,3) );
I0=FRAPData(RightAfterBleachframe ,3);
t=( FRAPData(RightAfterBleachframe:FitRange, 1) - RightAfterBleachframe ) *Interval;
y=  FRAPData(RightAfterBleachframe:FitRange, 3)./I1;

list = {'With immobile fraction','Without immobile fraction'};
[indx,tf] = listdlg('ListString',list,'SelectionMode','single');
if indx==1
    F = @(x,xdata)x(3)*(1-x(1)*exp(-xdata/x(2)));
elseif indx==2
    F = @(x,xdata)(1-x(1)*exp(-xdata/x(2)));
end
x0=[0.13 0.5 0.9];
[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,t,y);
x
p=plot( (FRAPData(:,1)-PreBleachFrame) * Interval, FRAPData(:,3) ./ I1,'*');
hold on
plot(t,F(x,t),'-k' )
hold off
outname=strcat(pwd,'\',name,'.mat');
save(outname);
xlabel('Time \itt\rm (s)')
ylabel('Intensity')
ax=gca;
ax.FontSize=20;
ax.FontName='Arial';


%%%check tif file
figure
colormap ('jet')
tiff_info = imfinfo(inputimage); % return tiff structure, one element per image
tiff_stack = imread(inputimage, 1) ; % read in first image
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread(inputimage, ii);
    tiff_stack = cat(3 , tiff_stack, temp_tiff);
end
sliceViewer(tiff_stack);
colormap ('jet');

