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

            k=1;
            Index_child{k}=answer{1};
            k=k+1;
        else
            Data=cat(1,Data,SumInt);

            Index=cat(1,Index,answer{1});

            FolerList=cat(1,FolerList,strcat(InputFileList(j).folder,'\',InputFileList(j).name));
            if strcmp(answer{1},Index_child{k-1,1})
            else
                Index_child{k,1}=answer{1};
                k=k+1;
            end
        end

    end
    totalfile=totalfile+1;


end


list = Index_child;
[indx,tf] = listdlg('ListString',list);

GroupIndex_child=str2double(Index_child);
GroupIndex=str2double(Index);

AllData=[Data, GroupIndex];
for k=1:length(GroupIndex_child)
    xdata(k)=GroupIndex_child(k);
    ydata(k)=mean(AllData(GroupIndex==GroupIndex_child(k),1));
    error(k)= std(AllData(GroupIndex==GroupIndex_child(k),1));
end

p=errorbar(xdata,ydata,error,'ks','MarkerFaceColor','k');
ax=gca; ax.FontSize=18; ax.FontName='Arial';
xlim([0 max(xdata)*1.1])
ylim([-inf inf])
xlabel('Time (min)');
xlabel('Concentration (mM)');
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