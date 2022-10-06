clear
close all

% path=uigetdir(pwd);
% cd (path)
LengthFolder=9;
totalfile=0;

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
AllData_X(:,6)=AllData_X(:,4)./pi ./ ( 4.0*AllData_X(:,2).*log(2));
DiffCoeff=[mean(AllData_X(:,6)), std(AllData_X(:,6))];
% % % Linear Fit
F = @(x,xdata)x(1)*xdata;
x0=0.3;
[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,AllData_X(:,4),AllData_X(:,2));
figure
hold on
plot(AllData_X(:,4), AllData_X(:,2),'*')
x_plot=[0:0.1:10];
plot(x_plot, F(x,x_plot),'k-')
hold off
% Option
ax=gca; ax.FontSize=18; ax.FontName='Arial';
% ax.XTickLabel={'Germ','Sperm', 'Early embryo','Embryo'};
% ax.XTickLabelRotation=45;
xlabel('Bleached area \fontname{Times}\it{A}\rm\fontname{Arial} (μm^2)')
ylabel('Characteristic time \fontname{Times}\itT_{\rmc}\rm\fontname{Arial} (s)')
l=legend('Exp.','Fit');
l.Location='northwest';
l.FontName='Arial';
l.FontSize=14;


% % % boxplot
figure
b=boxchart(AllData_X(:,5)/10,AllData_X(:,6));
b.BoxWidth=10;
xlim ([0-b.BoxWidth max(AllData_X(:,5))/10+b.BoxWidth])
ylim ([0 inf])
xticks([0 max(AllData_X(:,5))/10])
ax=gca; ax.FontSize=18; ax.FontName='Arial';
xticklabels({'WO PlasMem','PlasMem'})
ylabel 'Diffusion coefficient \fontname{Times}\itD\rm\fontname{Arial} (μm^2/s)'

% % % ------T-test
% x=AllData_X( ( AllData_X(:,4)==1 ) ,2);
% y=AllData_X( ( AllData_X(:,4)==2 ) ,2);
% [h,p] =ttest2(x,y)
