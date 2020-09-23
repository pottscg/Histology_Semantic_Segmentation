% Matlab's Semantic Segmentation Examples -- running through the code to
% see the data structures etc. 

%% Set up data

dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
imageDir = fullfile(dataSetDir,'trainingImages');
labelDir = fullfile(dataSetDir, 'trainingLabels');

% create an image datastore for the images
imds = imageDatastore(imageDir);

%create a pixel label datastore for ground truth pixel labels

classNames = ["triangle","background"]; % -- for classification
labelIDs = [255 0]; % -- info found in datastore??
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize training images and ground truth pixel labels
I = read(imds);
C = read(pxds);

I = imresize(I,5);
L = imresize(uint8(C{1}),5);
imshowpair(I,L,'montage');

%% Create Semantic Segmentation Network

numFilters = 64;
filterSize = 3;
numClasses = 2;
layers = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize, numFilters, 'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1)
    convolution2dLayer(1,numClasses)
    softmaxLayer()
    pixelClassificationLayer()
    ]

% training options
opts = trainingOptions('sgdm', ... 
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'MiniBatchSize',64);

% pixel label image database that contains training data
trainingData = pixelLabelImageDatastore(imds,pxds);

% train the network
net = trainNetwork(trainingData, layers, opts);

%% Validation

%read and test image
testImage = imread('triangleTest.jpg');
figure; imshow(testImage); 

C = semanticseg(testImage,net);
B = labeloverlay(testImage, C);
figure; imshow(B);

%% Adjust network to manage class mismatch

tbl = countEachLabel(trainingData)

totalNumberofPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberofPixels;
classWeights = 1./frequency

%update classification layer
layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

% train again
net = trainNetwork(trainingData, layers, opts);

%% Retest network example
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
figure; imshow(B);