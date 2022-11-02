% % % Images are converted from .fig to others.
clear; close all;
addpath(pwd);
[input_matimage, path]=uigetfile(strcat(pwd,'\.fig'));
listfile=dir(strcat(path,'*.fig'));
cd (path)
openfig(listfile(1).name);
answer_fig = questdlg('Would you like to convert?', ...
    'Question','Yes','No','Cancel');
switch answer_fig
    case 'Yes'
        for i=1:length(listfile)
            [folder, name, ext]=fileparts(listfile(i).name);
            openfig(listfile(i).name);
            outname=strcat(pwd,'\',name,'.png');
            exportgraphics(gcf,outname,"Resolution",600);
            close all
        end

    case 'No'
        return;
    case 'Cancel'
        return;
end

