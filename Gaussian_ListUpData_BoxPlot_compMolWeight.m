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
    InputFileList=dir(strcat(InputFolderList{i},'\Gaussian-*.mat'));

    for j=1:length(InputFileList)
        load(strcat(InputFileList(j).folder,'\',InputFileList(j).name), '-mat','DiffCoef','Fit_initial_Para');
        if i==1 && j==1
            DiffusionCoefficient(j,1)=DiffCoef;
            Initial_parameters(j,1:3)=Fit_initial_Para;
            Index{j,1}=answer{1};
            M(j,1)=str2double(answer{2});
        else
            DiffusionCoefficient=cat(1,DiffusionCoefficient,DiffCoef);
            Initial_parameters=cat(1,Initial_parameters,Fit_initial_Para);
            Index=cat(1,Index,answer{1});
            M=cat(1,M,str2double(answer{2}) );
        end
    end
    totalfile=totalfile+1;
end
Index=categorical(Index);
T=table(DiffusionCoefficient,Initial_parameters,Index,M);
b=boxchart(categorical(T.Index),T.DiffusionCoefficient);
b.BoxFaceColor='k';
b.MarkerStyle='+';
b.Notch='off'
ax=gca; ax.FontSize=18; ax.FontName='Arial';
% xlabel('Fluorophore')
ylabel('Diffusion coefficient \fontname{Times}\itD\rm\fontname{Arial} (μm^2/s)');
outputfolder=uigetdir(pwd);
exportgraphics(gcf,strcat(outputfolder,'\Result.png'),"Resolution",600);


% ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='FITC'))
% ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='RhoB'))
% ttest2(T.DiffusionCoefficient(T.Index=='F.G.'),T.DiffusionCoefficient(T.Index=='Uranine'))

% p_wilk=ranksum(T.DiffusionCoefficient(T.Index=='WT (N2)'),T.DiffusionCoefficient(T.Index=='et35'))

[p_anova,tb_anova,stats]=anova1(T.DiffusionCoefficient,T.Index);
% multcompare(stats);
% % % % 
% % Error propagation
M2=mean(M(T.Index=='RhoB'));
D2=mean(T.DiffusionCoefficient(T.Index=='RhoB'));
D1=mean(T.DiffusionCoefficient(T.Index=='F.G.'));
M_FG_RhoB(1,1)=M2*( D2/D1 )^3;
sigma2=(3*M2*D2^2/D1^3)^2*(std(T.DiffusionCoefficient(T.Index=='RhoB')))^2 ...
    + (-3*M2*D2^3/D1^4)^2*(std(T.DiffusionCoefficient(T.Index=='F.G.')))^2;
sigma_FG=sqrt(sigma2);
M_FG_RhoB(1,2)=sigma_FG;
% % % % 
save(strcat(outputfolder,'\Result.mat'));