clear
close all


totalfile=0;


LengthFolder=20;

for i=1:LengthFolder

    InputFolderList{i}=uigetdir(pwd);
    if InputFolderList{i}==0
        break;
    end
    prompt = {'Index:','Molecular Weight:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'F.G.','548'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    cd (InputFolderList{i})
    InputFileList=dir(strcat(InputFolderList{i},'\00*.mat'));

    for j=1:length(InputFileList)
        
        load(strcat(InputFileList(j).folder,'\',InputFileList(j).name), '-mat',...
            'FRAPData','PreBleachFrame','FitRange','Interval','I1','x','D');
        
        if i==1 && j==1
            Time(:,1)= (FRAPData(1:FitRange,1)-PreBleachFrame) * Interval;
            FRAPCurve(:,j)=FRAPData(1:FitRange,3) ./ I1;
            Index{j,1}=answer{1};
            M(j,1)=str2double(answer{2});
            FolerList{j,1}=strcat(InputFileList(j).folder,'\',InputFileList(j).name);
            FitData(j,:)=[x, D];
        else
            FRAPCurve=cat(2,FRAPCurve,FRAPData(1:FitRange,3) ./ I1);
            Index=cat(1,Index,answer{1});
            M=cat(1,M,str2double(answer{2}) );
            FolerList=cat(1,FolerList,strcat(InputFileList(j).folder,'\',InputFileList(j).name));
            FitData=cat(1,FitData,[x,D]);
        end
    end
    if i==1
        FRAPCurve_sum(:,1)=mean(FRAPCurve,2);
        FRAPCurve_sum=cat(2,FRAPCurve_sum,std(FRAPCurve,0,2));
    else
        FRAPCurve_sum=cat(2,FRAPCurve_sum,mean(FRAPCurve,2));
        FRAPCurve_sum=cat(2,FRAPCurve_sum,std(FRAPCurve,0,2));
    end
    totalfile=totalfile+1;
end
Index=categorical(Index);
T=table(FitData,Index,M,FolerList);
b=boxchart(categorical(T.Index),T.FitData(:,4));
b.BoxFaceColor='k';
b.MarkerStyle='+';
b.Notch='off';
ax=gca; ax.FontSize=18; ax.FontName='Arial';
% xlabel('Fluorophore')
ylabel('Diffusion coefficient \fontname{Times}\itD\rm\fontname{Arial} (μm^2/s)');
outputfolder=uigetdir(pwd);
savefig(strcat(outputfolder,'\Result-FRAPCurve-EstDiffCoeff.fig'));
% exportgraphics(gcf,strcat(outputfolder,'\Result.png'),"Resolution",600);

% [h_lillie,p_lillie,k_lillie,c_lillie] = lillietest(T.DiffusionCoefficient(T.Index=='Control'));

% p_wilk=ranksum(T.DiffusionCoefficient(T.Index=='WT (N2)'),T.DiffusionCoefficient(T.Index=='et35'))

[p_anova,tb_anova,stats]=anova1(T.FitData(:,4),T.Index);
% multcompare(stats);
% % % % 
% %
% FRAPCurve_sum(1,:)=mean(R,std(FRAPCurve,0,2));
errorbar(Time,FRAPCurve_sum(:,1),FRAPCurve_sum(:,2));
hold on
% errorbar(Time,FRAPCurve_sum(:,3),FRAPCurve_sum(:,4));
% errorbar(Time,FRAPCurve_sum(:,5),FRAPCurve_sum(:,6));
hold off

ax=gca; ax.FontSize=18; ax.FontName='Arial';
xlabel('Time \fontname{Times}\itt \fontname{Arial}\rm(s)')
ylabel('Intensity');
savefig(strcat(outputfolder,'\Result-FRAPCurve.fig'));
% % % % 
save(strcat(outputfolder,'\Result-FRAPCurve.mat'));