clear
close all

% path=uigetdir(pwd);
% cd (path)
totalfile=0;


LengthFolder=20;

for i=1:LengthFolder

    InputFolderList{i}=uigetdir(pwd);
    if InputFolderList{i}==0
        break;
    end

    cd (InputFolderList{i})
    InputFileList=dir(strcat(InputFolderList{i},'\Result*.mat'))
    for j=1:length(InputFileList)
        load(strcat(InputFileList(j).folder,'\',InputFileList(j).name))
        if i==1 && j==1
            AllData_X=X;
        else
            AllData_X=cat(1,AllData_X,X);
        end
    end
    totalfile=totalfile+1;
end

% % % % % % % intensity
figure
b=boxchart(AllData_X(:,size(AllData_X,2)),AllData_X(:,3))
% b=boxchart(log10(AllData(:,27)),AllData(:,20))
b.BoxWidth=0.5;
xlim ([0-b.BoxWidth inf])
ylim ([0 inf])
% Option
ax=gca
ax.FontSize=14;
ax.FontName='Arial';
% ax.XTick=[0 1 2];
% ax.XTickLabel={'Front','Middle', 'Rear'};
ax.XTickLabelRotation=45;
xlabel('Time')
ylabel('Intensity \itI (s)')

% % % % % % % % Mobile Fraction
% figure
% b=boxchart(AllData_X(:,size(AllData_X,2)),AllData_X(:,3))
% % b=boxchart(log10(AllData(:,27)),AllData(:,20))
% b.BoxWidth=0.5;
% xlim ([0-b.BoxWidth inf])
% ylim ([0 inf])
% % Option
% ax=gca
% ax.FontSize=14;
% ax.FontName='Arial';
% % ax.XTick=[0 1 2];
% % ax.XTickLabel={'Front','Middle', 'Rear'};
% ax.XTickLabelRotation=45;
% xlabel('Position')
% ylabel('Mobile fraction \itF_{\rm{m}}')
% 
% 

% % ------T-test
% x=AllData_X( ( AllData_X(:,size(AllData_X,2))==1 ) ,2);
% y=AllData_X( ( AllData_X(:,size(AllData_X,2))==2 ) ,2);
% [h,p] =ttest2(x,y)
