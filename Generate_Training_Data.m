function [Observed,Selection,m,n] = Generate_Training_Data(filepath,filename)
    
    FileTif = strcat(filepath,filename);
    InfoImage = imfinfo(FileTif);
    mImage = InfoImage(1).Width;
    nImage = InfoImage(1).Height;
    NumberImages = length(InfoImage);

    %storage for image layers
    FullImage = zeros(nImage, mImage, NumberImages, 'uint16');

    tifLink = Tiff(FileTif, 'r');
    for i = 1:NumberImages
        tifLink.setDirectory(i);
        FullImage(:,:,i) = tifLink.read();
    end
    tifLink.close();

    m = size(FullImage,1);
    n = size(FullImage,2);
    
    figure; title('Are the Channels correct?'); subplot(1,3,1); imagesc(FullImage(:,:,1));
    subplot(1,3,2); imagesc(FullImage(:,:,2));
    subplot(1,3,3); imagesc(FullImage(:,:,3));
    
    x = inputdlg({'Epethelial Channel','Dendridic Channel','Nuclei Channel'},...
              'Input Channels', [1 20; 1 20; 1 20]); 
          
    Shuffled = cat(3,FullImage(:,:,str2num(x{1})),FullImage(:,:,str2num(x{2})),FullImage(:,:,str2num(x{3})));

    figure; title('Shuffled Channels'); subplot(1,3,1); imagesc(Shuffled(:,:,1));
    subplot(1,3,2); imagesc(Shuffled(:,:,2));
    subplot(1,3,3); imagesc(Shuffled(:,:,3));
    
    ROIs = selection_logical(strcat(filepath,'Selection.csv'));
    
    %padd ones if size doesn't match and error is thrown
    ROIs = padarray(ROIs',[abs(size(FullImage(:,:,str2num(x{3})),2)-size(ROIs,2)) 2],1,'post')';
    ROIs = padarray(ROIs',[abs(size(FullImage(:,:,str2num(x{3})),1)-size(ROIs,1)) 1],1,'post')';

    % adjust size if ROI doesn't match image size
     ROIs = ROIs(1:size(FullImage(:,:,str2num(x{3})),1),1:size(FullImage(:,:,str2num(x{3})),2));
    
%      figure; imagesc(ROIs);
    
    Observed = {};
    Selection = {};
    
    data_index = 1;
    n_step = 1;
    m_step = 1;
    step = 32;
    
    for j = 1: floor((n-1)/step) 
        n_step = n_step + step;
%         disp(n_step);
        m_step = 1;
        for k = 1: floor((m-1)/step) 
            m_step = m_step + step;
%              disp(m_step);
            Observed{data_index} = Shuffled(m_step-step:m_step,n_step-step:n_step,:);
            Selection{data_index} = ROIs(m_step-step:m_step,n_step-step:n_step);
        
            if( k ==1 && j ==1)
                figure; subplot(2,2,1); imagesc(Shuffled(n_step-step:n_step,m_step-step:m_step,1));
                subplot(2,2,2); imagesc(Shuffled(n_step-step:n_step,m_step-step:m_step,2));
                subplot(2,2,3); imagesc(Shuffled(n_step-step:n_step,m_step-step:m_step,3));
                subplot(2,2,4); imagesc(ROIs(n_step-step:n_step,n_step-step:m_step));
            end
            
            data_index = data_index +1;
        end
    end

end