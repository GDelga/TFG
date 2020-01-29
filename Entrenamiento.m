clear all; close all;

% ejemplo tomado de: 
% https://es.mathworks.com/help/nnet/ref/alexnet.html

%unzip('MerchData.zip');
imds = imageDatastore('Vehiculos',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

[imdsTrain,imdsValidation] = splitEachLabel(imds,0.9,'randomized');

numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,64);
figure
for i = 1:64
    subplot(8,8,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end

% load netlayer
net = alexnet;

inputSize = net.Layers(1).InputSize;

%% Seguimos las instrucciones teniendo en cuenta lo descrito en la siguiente dirección:
% https://es.mathworks.com/help/nnet/ref/alexnet.html#bvnzu37

% Replace Final Layers
% The last three layers of the pretrained network net are configured for 1000 classes. These three layers must be fine-tuned for the new classification problem. Extract all layers, except the last three, from the pretrained network.

layersTransfer = net.Layers(1:end-3);

%Transfer the layers to the new classification task by replacing the last three layers with a fully connected layer, a softmax layer, and a classification output layer. Specify the options of the new fully connected layer according to the new data. Set the fully connected layer to have the same size as the number of classes in the new data. To learn faster in the new layers than in the transferred layers, increase the WeightLearnRateFactor and BiasLearnRateFactor values of the fully connected layer.
numClasses = numel(categories(imdsTrain.Labels));

layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% Train Network
%The network requires input images of size 227-by-227-by-3, but the images in the image datastores have different sizes. Use an augmented image datastore to automatically resize the training images. Specify additional augmentation operations to perform on the training images: randomly flip the training images along the vertical axis, and randomly translate them up to 30 pixels horizontally and vertically. Data augmentation helps prevent the network from overfitting and memorizing the exact details of the training images.

pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);

%% OJO augmentedImageDatastore sólo funciona para Matlab 2018a
% augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
%    'DataAugmentation',imageAugmenter);

%%% To automatically resize the validation images without performing further data augmentation, use an augmented image datastore without specifying any additional preprocessing operations.
%augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%%%Specify the training options. For transfer learning, keep the features from the early layers of the pretrained network (the transferred layer weights). To slow down learning in the transferred layers, set the initial learning rate to a small value. In the previous step, you increased the learning rate factors for the fully connected layer to speed up learning in the new final layers. This combination of learning rate settings results in fast learning only in the new layers and slower learning in the other layers. When performing transfer learning, you do not need to train for as many epochs. An epoch is a full training cycle on the entire training data set. Specify the mini-batch size and validation data. The software validates the network every ValidationFrequency iterations during training.

options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');

%Train the network that consists of the transferred and new layers. By default, trainNetwork uses a GPU if one is available (requires Parallel Computing Toolbox™ and a CUDA® enabled GPU with compute capability 3.0 or higher). Otherwise, it uses a CPU. You can also specify the execution environment by using the 'ExecutionEnvironment' name-value pair argument of trainingOptions.
netTransfer = trainNetwork(imdsTrain,layers,options);

save netTransfer netTransfer

%% Classify Validation Images
% Classify the validation images using the fine-tuned network.

[YPred,scores] = classify(netTransfer,imdsValidation);
%Display four sample validation images with their predicted labels.

idx = randperm(numel(imdsValidation.Files),6);
figure
for i = 1:6
    subplot(3,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end

%% Visualización de los pesos

% Get the network weights for the second convolutional layer
w1 = netTransfer.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5);

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
figure
montage(w1)
title('First convolutional layer weights')

