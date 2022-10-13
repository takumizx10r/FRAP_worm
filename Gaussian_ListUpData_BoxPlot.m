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
    definput = {'F.G.','X'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    cd (InputFolderList{i})
    InputFileList=dir(strcat(InputFolderList{i},'\Gaussian-*.mat'));

    for j=1:length(InputFileList)
        load(strcat(InputFileList(j).folder,'\',InputFileList(j).name), '-mat','DiffCoef');
        if i==1 && j==1
            DiffusionCoefficient(j,1)=DiffCoef;
            Index{j,1}=answer{1};
            M(j,1)=str2double(answer{2});
        else
            DiffusionCoefficient=cat(1,DiffusionCoefficient,DiffCoef);
            Index=cat(1,Index,answer{1});
            M=cat(1,M,str2double(answer{2}) );

        end
    end
    totalfile=totalfile+1;
end
Index=categorical(Index);
T=table(DiffusionCoefficient,Index,M);
b=boxchart(categorical(T.Index),T.DiffusionCoefficient);
b.BoxFaceColor='k';
b.MarkerStyle='+';
ax=gca; ax.FontSize=18; ax.FontName='Arial';
xlabel('Fluorophore')
ylabel('Diffusion coefficient \fontname{Times}\itD\rm\fontname{Arial} (μm^2/s)')

ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='FITC'))
ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='RhoB'))
ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='Uranine'))
