clear
close all


addpath(pwd);
[inputimage, path]=uigetfile(strcat(pwd,'\.tif'));
listfile=dir(strcat(path,'00*.tif'));
cd (path)
tiff_info_first = imfinfo(listfile(1).name);

prompt = {'Frame interval (s):','Num of prebleach frames:',...
    'Right after bleach frame:','Fit start frame:',...
    'Pixel size (pix/um):','Number of total frame:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'0.0884','2','3','3', sprintf('%.5f',tiff_info_first(1).XResolution),'60'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
Interval=str2double(answer{1});
PreBleachFrame=str2num(answer{2});
RightAfterBleachframe=str2num(answer{3});
FitRange_start=str2num(answer{4});
pix_size=str2double(answer{5});
Num_frame=str2num(answer{6});


answer_fig = questdlg('Would you like to make fiugres and movie?', ...
    'Question','Yes','No','Cancel');
switch answer_fig
    case 'Yes'
        figure_config = 1;
        prompt = {'Scale bar (um, if 0; no scale bar):'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {'5'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        scalebar=str2double(answer{1});
    case 'No'
        figure_config= 0;
    case 'Cancel'
        return;
end


for file=1:size(listfile,1)
    clear imData imData_d im_fit_Data
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
    DiffCoef=FitPara/pix_size/pix_size;
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
    if figure_config==1
        outfolder=strcat(pwd,'\Gaussian-Dist-',name);
        mkdir (outfolder);
        for frame=1:size(im_fit_Data,3)
            f=gcf;
            f.Position=[1 1 600 600]; f.Units='pixels';
            clims=[0 1];
            colormap 'jet'
            % % %             tiledlayout(2,1)
            % % %             ax1 = nexttile; ax1.FontName='Arial'; ax1.FontSize=18;
            % % %             mesh(im_fit_Data(:,:,frame));
            % % %             zlim([0 1.2])
            % % %             hold on
            % % %             imagesc(im_fit_Data(:,:,frame),clims)
            % % %             hold off
            % % %             xlabel 'x'; ylabel 'y'; zlabel 'Intensity';
            % % %             text(size(im_fit_Data,2)*0.3,size(im_fit_Data,1),1.4,sprintf('%.1f (ms)',Interval*(frame-1)*1000))
            % % %             ax2 = nexttile;
            % % %             ax2.FontName='Arial'; ax2.FontSize=18;
            % % %             mesh(RegressionDist(:,:,frame));
            % % %             zlim([0 1.2])
            % % %             hold on
            % % %             imagesc(RegressionDist(:,:,frame),clims)
            % % %             hold off
            % % %             xlabel 'x'; ylabel 'y'; zlabel 'Intensity';

            pos1 = [0.10 0.25 0.4 0.4];
            pos2 = [0.55 0.25 0.4 0.4];
            pos3 = [0.10 0.675 0.25 0.02];
            ax1=subplot('Position',pos1);
            ax2=subplot('Position',pos2);
            ax3=subplot('Position',pos3);

            subplot(ax1);
            axtoolbar('Visible','off');
            imagesc(im_fit_Data(:,:,frame),clims);
            text(size(im_fit_Data,2)*0.65,size(im_fit_Data,1)*0.1,...
                sprintf('%.0f (ms)',Interval*(frame-1)*1000), ...
                "Color",'w','FontSize',14);
            %             xlabel '\itx \rm(pixel)';
            %             ylabel '\ity \rm(pixel)';
            % % %             Scale bar
            if scalebar>0
                hold on
                plot([size(im_fit_Data,2)*0.1 ; size(im_fit_Data,2)*0.1+pix_size*scalebar],...
                    [size(im_fit_Data,1)*0.1;size(im_fit_Data,1)*0.1],'-w','LineWidth',1);
                plot([size(im_fit_Data,2)*0.1 ; size(im_fit_Data,2)*0.1],...
                    [size(im_fit_Data,1)*0.1;size(im_fit_Data,1)*0.1+pix_size*scalebar],'-w','LineWidth',1);
                hold off
            end
            % % %
            yticks([]);xticks([]);
            subplot(ax2);
            imagesc(RegressionDist(:,:,frame),clims)
            %             text(size(im_fit_Data,2)*0.7,size(im_fit_Data,1)*0.1,...
            %                 sprintf('%.0f (ms)',Interval*(frame-1)*1000), ...
            %                 "Color",'w','FontSize',12);
            %             xlabel '\itx \rm(pixel)';
            yticks([]);xticks([]);

            subplot(ax3);
            CM2=colormap(ax3, jet);
            y = [0:0.01:1];
            x = [0:0.5:1.0];
            [X,Y] = meshgrid(y,flip(y));
            imagesc(X);
            ax3.YAxis.Visible='off';
            ax3.XTick=[1 101];
            ax3.XTickLabel={'0','1'};
            ax3.XAxisLocation = 'top';
            xlabel('Intensity');
            axtoolbar('Visible','off');

            ax1.FontName='Arial'; ax1.FontSize=14;
            ax2.FontName='Arial'; ax2.FontSize=14;
            ax3.FontName='Arial'; ax3.FontSize=14;

            fig(frame)=getframe(f);

            outname=strcat(outfolder,'\',sprintf('%03d.fig',frame));
            savefig(outname);
            %                         outname=strcat(outfolder,'\',sprintf('%03d.png',frame));
            %                         exportgraphics(gcf,outname,"Resolution",600);

        end
        v=VideoWriter(strcat(outfolder,'\movie'),"MPEG-4");
        v.FrameRate=size(im_fit_Data,3)/3;
        open(v);
        writeVideo(v,fig);
        close(v);
        clear v fig
        close all
    end
    % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % f_color=figure;

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


function F_=func_C(para_ini,r,t,D)
F_= para_ini(1)-para_ini(2)/(para_ini(3)+4.0*D*t)...
    *exp( -r*r/(para_ini(3) + +4.0*D*t) );
end
