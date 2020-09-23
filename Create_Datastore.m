function Create_Datastore(Observed, Selection,path)

for i = 1:size(Observed,2)
    image = uint8(Observed{i});
    image = image(2:size(image,1),2:size(image,2),:);
    selection = Selection{i};
    selection = selection(2:size(selection,1),2:size(selection,2));
    if i < 10
        index = strcat('0000',num2str(i));
    else if i < 100
            index = strcat('000',num2str(i));
        else if i < 1000
                index = strcat('00',num2str(i));
            else if i < 10000
                index = strcat('0',num2str(i));
                else
                    index = num2str(i);
                end
        end
    end
    end
           
    imwrite(image,strcat('DATASTORE/',path,'obs',index,'.png'));
    imwrite(selection,strcat('LABELSTORE/',path,'label',index,'.png'));
end
end