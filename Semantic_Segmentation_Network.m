%% Training and Testing Data

num_images = size(Observed, 2);
num_train = floor(0.6*num_images);
num_test = num_images - num_train;
index = 1:num_images;

train_index = randi([1 num_images],1,num_train);
Observed_Train = {};
Selection_Train = {};
Observed_Test = {};
Selection_Test = {};
train_step = 1;
test_step = 1;
for i = 1:num_images
    if any(train_index(:) == i)
        Observed_Train{train_step} = Observed{i};
        Selection_Train{train_step} = categorical(reshape(Selection{i},1,[]),[0 1],{'Out' 'In'});
        train_step = train_step +1;
    else 
        Observed_Test{test_step} = Observed{i};
        Selection_Test{test_step} = categorical(reshape(Selection{i},1,[]),[0 1],{'Out' 'In'});
        test_step = test_step +1;
    end
end

Observed_Test = cat(4,Observed_Test{:});
Selection_Test = cat(2,Selection_Test{:});
Observed_Train = cat(4,Observed_Train{:});
Selection_Train = cat(2,Selection_Train{:});

% Selection_Test = categorical(Selection_Test);
% Selection_Train = categorical(Selection_Train);

% test_index = index(~train_index);
% 
% for i = 1:num_test
%    Observed_Test{i} = Observed{test_index(i)};
%    Selection_Test{i} = Observed{test_index(i)};
% end

%% ImageData Store, PixelData store

imDir = fullfile('DATASTORE','200by200');
pxDir = fullfile('LABELSTORE','200by200');

imds = imageDatastore(imDir,'FileExtensions','.png');

classNames = ["epethelial","background"];
pixelLabelID = [1 0];
pxds = pixelLabelDatastore(pxDir, classNames, pixelLabelID,'FileExtensions','.png');


% [train, test] = splitEachLabel(pximds, 0.8, 'randomized');

%% Build Architecture

numFilters = 32;
filterSize = 3;
numClasses = 2;
layers = [
    imageInputLayer([200 200 3])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()    
    maxPooling2dLayer(2,'Stride',2)  
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    reluLayer()
    convolution2dLayer(1,numClasses)
    softmaxLayer()
    pixelClassificationLayer()
    ]

% training options
opts = trainingOptions('sgdm', ... 
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'MiniBatchSize',64);

pximds = pixelLabelImageDatastore(imds,pxds);

% train network
net = trainNetwork(pximds, layers, opts);

%% Validate Network

% pxdsResults = semanticseg(

