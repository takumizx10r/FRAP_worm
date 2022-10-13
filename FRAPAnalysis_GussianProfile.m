clear
close all



[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
listfile=dir(strcat(path,'00*.tif'));
cd (path)

prompt = {'Frame interval (s):','Prebleach frames:',...
            'Right after bleach frame:','Fit start frame:',...
            'Pixel size (pix/um):','Number of total frame:'};
dlgtitle = 'Input';
dims = [1 35];  
definput = {'0.0884','2','3','3','4.0111','60'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
Interval=str2double(answer{1});
PreBleachFrame=str2num(answer{2});
RightAfterBleachframe=str2num(answer{3});
FitRange_start=str2num(answer{4});  
pix_size=str2double(answer{5});  
Num_frame=str2num(answer{6});

for file=1:size(listfile,1)

inputimage=listfile(file).name;
tiff_info = imfinfo(inputimage);
for i=1:Num_frame
imData(:,:,i) = imread(inputimage, i);
end

imData_d=double(imData);
pre_imData=imData_d(:,:,1:PreBleachFrame);
im_fit_Data=imData_d(:,:,FitRange_start:size(imData_d,3))...
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

% % % FITTING INITIAL PARAMETERS
Fit_initial_Para=func_leastsquare_with_GaussianDist_determineInitialPara(im_fit_Data(:,:,1),center);
% % % OBTAIN REGRESSION DISTRIBUTION AT T=0
RegressionDist=zeros(size(im_fit_Data,1),size(im_fit_Data,2),size(im_fit_Data,3));
for k=1:1
    for j=1:size(im_fit_Data,1)
        for i=1:size(im_fit_Data,2)
            R= sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                    + (j-center(1,2)) * (j-center(1,2) ) );
            t=Interval*(k-1);
            RegressionDist(j,i,k)=func_C(Fit_initial_Para,R,t,0);
        end
    end
end

% % % FITTING DIFFUSION COEFFICIENT WITH INITIAL PARAMETERS
FitPara=...
func_leastsquare_with_GaussianDist(im_fit_Data(:,:,:),center,Fit_initial_Para,Interval);
DiffCoef=FitPara/pix_size;
% % % OBTAIN REGRESSION DISTRIBUTION AT EACH TIMES
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
% % % % % 
% % OUTPUT FIGURES - MAKE DIST
outfolder=strcat(pwd,'\Gaussian-Dist-',name);
mkdir (outfolder);
for frame=1:size(im_fit_Data,3)
    
    clims=[0 1];
    colormap 'jet'
    tiledlayout(2,1)
    ax1 = nexttile; ax1.FontName='Arial'; ax1.FontSize=18;
    mesh(im_fit_Data(:,:,frame));
    zlim([0 1.2])
    hold on
    imagesc(im_fit_Data(:,:,frame),clims)
    hold off
    xlabel 'x'; ylabel 'y'; zlabel 'Intensity';
    text(20,70,1.5,sprintf('%.1f (ms)',Interval*(frame-1)*1000))
    ax2 = nexttile;
    ax2.FontName='Arial'; ax2.FontSize=18;
    mesh(RegressionDist(:,:,frame));
    zlim([0 1.2])
    hold on
    imagesc(RegressionDist(:,:,frame),clims)
    hold off
    xlabel 'x'; ylabel 'y'; zlabel 'Intensity';
    outname=strcat(outfolder,'\',sprintf('%03d.png',frame));
    exportgraphics(gcf,outname,"Resolution",600);
end

% % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % f_color=figure;
% % % % % % % % % % % % % % % % % % % % % % % pos1 = [0.05 0.25 0.4 0.4];
% % % % % % % % % % % % % % % % % % % % % % % pos2 = [0.55 0.25 0.4 0.4];
% % % % % % % % % % % % % % % % % % % % % % % pos3 = [0.70 0.72 0.25 0.02];
% % % % % % % % % % % % % % % % % % % % % % % ax1=subplot('Position',pos1);
% % % % % % % % % % % % % % % % % % % % % % % ax2=subplot('Position',pos2);
% % % % % % % % % % % % % % % % % % % % % % % ax3=subplot('Position',pos3);
% % % % % % % % % % % % % % % % % % % % % % % subplot(ax1);
% % % % % % % % % % % % % % % % % % % % % % % axtoolbar('Visible','off');
% % % % % % % % % % % % % % % % % % % % % % % imagesc(im_fit_Data(:,:,1),clims)
% % % % % % % % % % % % % % % % % % % % % % % hold on
% % % % % % % % % % % % % % % % % % % % % % % % scatter(center(1,1),center(1,2),'MarkerFaceColor','k')
% % % % % % % % % % % % % % % % % % % % % % % hold off
% % % % % % % % % % % % % % % % % % % % % % % subplot(ax2);
% % % % % % % % % % % % % % % % % % % % % % % imagesc(RegressionDist(:,:,1),clims)
% % % % % % % % % % % % % % % % % % % % % % % hold on
% % % % % % % % % % % % % % % % % % % % % % % % scatter(center(1,1),center(1,2),'MarkerFaceColor','k')
% % % % % % % % % % % % % % % % % % % % % % % hold off
% % % % % % % % % % % % % % % % % % % % % % % subplot(ax3);
% % % % % % % % % % % % % % % % % % % % % % % CM2=colormap(ax3, jet);
% % % % % % % % % % % % % % % % % % % % % % % y = [0:0.01:1];
% % % % % % % % % % % % % % % % % % % % % % % x = [0:0.5:1.0];
% % % % % % % % % % % % % % % % % % % % % % % [X,Y] = meshgrid(y,flip(y));
% % % % % % % % % % % % % % % % % % % % % % % imagesc(X);
% % % % % % % % % % % % % % % % % % % % % % % ax3.YAxis.Visible='off';
% % % % % % % % % % % % % % % % % % % % % % % ax3.XTick=[1 50 101];
% % % % % % % % % % % % % % % % % % % % % % % ax3.XTickLabel={'0',' 0.5','1'};
% % % % % % % % % % % % % % % % % % % % % % % xlabel('Intensity');
% % % % % % % % % % % % % % % % % % % % % % % axtoolbar('Visible','off');
% % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % sliceViewer(RegressionDist);
% % % % % % % % % % % % % % % % % % % % % % % colormap ('jet');
% % % % % % % % % % % % % % % % % % % % % % % sliceViewer(im_fit_Data);
% % % % % % % % % % % % % % % % % % % % % % % colormap ('jet');
% % % % % % % % % % % % % % % % % % % % % % % disp(DiffCoef);

outname=strcat(pwd,'\Gaussian-',name,'.mat');
save(outname);

end


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
