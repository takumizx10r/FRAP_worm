clear 
close all

path=uigetdir(pwd);

prompt = {'Enter group index;'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'0'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
GroupIdex= str2num(answer{1});

inputfilelist   =   dir(strcat(path,'\0*.mat'));
C=strsplit(inputfilelist(1).folder, '\\');
for i=1:length(inputfilelist)
    if i==1
        load(strcat(inputfilelist(i).folder,'\',inputfilelist(i).name))
        X=x;
        X(:,4)=FRAPData(1,2); %%%Area
        
    else
        load(strcat(inputfilelist(i).folder,'\',inputfilelist(i).name))
        X=cat(1,X,[x,FRAPData(1,2)]);
    end

end
X(:,size(X,2)+1)=GroupIdex
cd (inputfilelist(1).folder)
save('Result.mat','X','C')