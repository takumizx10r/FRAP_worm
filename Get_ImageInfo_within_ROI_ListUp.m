clear
close all


totalfile=0;


LengthFolder=20;

for i=1:LengthFolder

    InputFolderList{i}=uigetdir(pwd);
    if InputFolderList{i}==0
        break;
    end
    prompt = {'Index:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'10 mM'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    cd (InputFolderList{i})
    InputFileList=dir(strcat(InputFolderList{i},'\ResultInRoi-*.mat'));

    for j=1:length(InputFileList)
        
        load(strcat(InputFileList(j).folder,'\',InputFileList(j).name), '-mat',...
            'SumInt');
        
        if i==1 && j==1
            Data(j,:)=SumInt;

            Index{j,1}=answer{1};

            FolerList{j,1}=strcat(InputFileList(j).folder,'\',InputFileList(j).name);
        else
            Data=cat(1,Data,SumInt);

            Index=cat(1,Index,answer{1});

            FolerList=cat(1,FolerList,strcat(InputFileList(j).folder,'\',InputFileList(j).name));
        end
    end
    totalfile=totalfile+1;
    
    
end
GroupIndex=str2double(Index);
AllData=[Data, GroupIndex];
xdata=[30;60;120;180;360;720;1200];
ydata=[ mean(AllData(GroupIndex==30,1));...
        mean(AllData(GroupIndex==60,1));...
        mean(AllData(GroupIndex==120,1));...
        mean(AllData(GroupIndex==180,1));...
        mean(AllData(GroupIndex==360,1));...
        mean(AllData(GroupIndex==720,1));...
        mean(AllData(GroupIndex==1200,1))];
error=[ std(AllData(GroupIndex==30,1));...
        std(AllData(GroupIndex==60,1));...
        std(AllData(GroupIndex==120,1));...
        std(AllData(GroupIndex==180,1));...
        std(AllData(GroupIndex==360,1));...
        std(AllData(GroupIndex==720,1));...
        std(AllData(GroupIndex==1200,1))];
p=errorbar(xdata,ydata,error,'ks','MarkerFaceColor','k');
ax=gca; ax.FontSize=18; ax.FontName='Arial';
xlim([0 max(xdata)*1.1])
ylim([-inf inf])
xlabel('Time (min)');
ylabel('Intensity');
outputfolder=uigetdir(pwd);
savefig(strcat(outputfolder,'\Result.fig'));
exportgraphics(gcf,strcat(outputfolder,'\Result.png'),"Resolution",600);

% % % Make Table
Index=categorical(Index);
T=table(Data,Index,FolerList);
% b=boxchart(categorical(T.Index),T.Data(:,1));
% % hold on; plot(categorical(T.Index),T.Data(:,1),'.k'); hold off;
% b.BoxFaceColor='k';
% b.MarkerStyle='+';
% b.Notch='on';
% b.JitterOutliers='off';
% ax=gca; ax.FontSize=18; ax.FontName='Arial';
% % xlabel('Fluorophore')
% ylabel('Intensity');
% outputfolder=uigetdir(pwd);
% f=gcf;
% f.Position=[1 1 600 600]; f.Units='pixels';
% savefig(strcat(outputfolder,'\Result.fig'));
% exportgraphics(gcf,strcat(outputfolder,'\Result.png'),"Resolution",600);

% [h_lillie,p_lillie,k_lillie,c_lillie] = lillietest(T.DiffusionCoefficient(T.Index=='Control'));

% p_wilk=ranksum(T.DiffusionCoefficient(T.Index=='WT (N2)'),T.DiffusionCoefficient(T.Index=='et35'))
% 
% [p_anova,tb_anova,stats]=anova1(T.DiffusionCoefficient,T.Index);
% % multcompare(stats);


% bp=boxplot(T.Data,GroupIndex);
% bp.BoxFaceColor='k';
% b.MarkerStyle='+';
% b.Notch='on';
% b.JitterOutliers='off';
% ax=gca; ax.FontSize=18; ax.FontName='Arial';
% xlabel('Fluorophore')
% ylabel('Intensity');
% savefig(strcat(outputfolder,'\Result.fig'));
% % % % 
save(strcat(outputfolder,'\Result.mat'));