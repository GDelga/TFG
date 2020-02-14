% Borrar todas las variables del espacio de trabajo.
clear;

% Cierra todos los gráficos que se estén mostrando.
close all;

% Almacén de imágenes, toma la estructura de las carpetas y subcarpetas.
vehicleImageDataStore = imageDatastore('Vehiculos','IncludeSubfolders', true,'LabelSource','foldernames');

% Divide el imageDatastore en dos imageDatastore con un reparto aleatorio de imágenes (90%,10%).
[imageDataStoreForTraining , imageDataStoreForValidation] = splitEachLabel(vehicleImageDataStore,0.9,'randomized');

%% Carga y readaptaptación de la red neuronal AlexNet

% Cargamos la red neuronal AlexNet.
network = alexnet;

% Extraemos las capas de la red neuronal.
networkLayers = network.Layers;

% Extraemos el tamaño de la entrada de la primera capa.
inputSize = networkLayers(1).InputSize;

% Extracción de las N - 3 capas de AlexNet. 
transferedLayers = networkLayers(1:end-3);

% Obtenemos el número de clases del problema de clasificación.
numClasses = numel(categories(imageDataStoreForTraining.Labels));

%{
Readaptamos la red neuronal: Realizamos la transferencia de aprendizaje
conservando las N - 3 capas de la red AlexNet original, las cuales ya
están entrenadas y solamente necesitan un bajo valor del factor de 
aprendizaje. Las últimas 3 capas han de cambiarse para adaptar la red 
AlexNet al nuevo problema de clasificación. Estas necesitan ser entrenadas.
y tendrán un factor de aprendizaje más alto. 

Esta configuración permitirá un aprendizaje más rápido en las nuevas
capas, por el contrario, este será más lento en las capas antiguas.

Capas añadidas (Capas de tipo 2D):

    * fullyConnectedLayer: 

        Una capa en la cual cada neurona está conectada a cada neurona de 
        la capa anterior.

        Esta capa toma los resultados de los procesos de convolution 
        (convolución) y pooling (agrupación) para su uso en la
        determinación de la clase a la que pertenece una imágen.

        La salida de convolution y pooling se aplanan/transforman (flatten)
        en un vector de 1xN valores, siendo cado uno de esos valores una
        probabilidad de cuan vinculada está cierta característica a la
        pertenencia a una clase.

        Ejemplo: Si tenemos una imagen de un coche, las características que
        que representan elementos como: Ruedas, capó, retrovisores, etc ... 
        Deben contener altas probabilidades para que la imagen pueda 
        pertenecer a la clase coche.

    * softmaxLayer: 
        
        Es la capa que se ocupa de calcular las probabilidades de 
        pertenencia de una imagen a cada clase. Su salida es un vector
        que contiene en cada posición un valor en el rango [0 - 1] que 
        representa la probabilidad de pertenencia de la imagen a cada clase 
        del problema de clasificación.

    * classificationLayer: 

        Esta capa recibe la probabilidad de pertenencia de una imagen a 
        cada clase del problema de clasificación.

%}
layers = [
    transferedLayers
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer
];

%% Entrenamiento de la red neuronal AlexNet

%{
imageDataAugmenter permite definir un conjunto de opciones para el
preprocesamiento de imágenes, entre ellas se encuentra el redimensionado,
la rotación, la reflexión, etc.
%}
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ... % Reflexión de izquierda-derecha, 50%.
    'RandXTranslation', [-30 30], ... Rango para la translación horizontal.
    'RandYTranslation', [-30 30] ... Rango para la translación vertical.
);

%{
El objeto augmentedImageDatastore es parecido al imageDatastore con la 
peculiaridad que dada una serie de opciones de preprocesamiento, es capaz 
de añadir nuevas imagenes distosionadas de las originales, lo que permite 
aumentar el número de imagenes del conjunto entrenamiento.

Entrenar la red con imágenes distorsionadas aumenta la cantidad de 
información que la red puede obtener de estas, además previene el 
sobreajustamiento (Overfitting) y que la red tenga que memorice detalles
exactos de las imágenes de nuestro set de entrenamiento.

Overfitting: Este concepto indica que la red neuronal aprende mucho sobre 
los datos de entrenamiento pero tiene un desempeño pobre al clasificar los 
datos de validación u otros datos que nunca ha visto.

Este set de imágenes se usará para entrenar AlexNet y así esta pueda
autoajustar los pesos/tensores de las neuronas.
%}
aumentedImageDataStoreForTraining = augmentedImageDatastore( ...
    inputSize(1:3), ... % Tamaño de las imágenes de salida (227,227,3).
    imageDataStoreForTraining, ... % DataStore original.
    'DataAugmentation', imageAugmenter, ... % Opciones de distorsión.
    'ColorPreprocessing', 'gray2rgb' ... % Pasar de grises a rgb.
);

%{
El set de imágenes de validacion permite verificar si la clasificacion es 
correcta, si falla en exceso entonces el entrenamiento no ha sido correcto 
ya que se necesita aumentar el conjuto de datos de entrenamiento.
%}
aumentedImageDataStoreForValidation = augmentedImageDatastore( ...
    inputSize(1:3), ... % Tamaño de las imágenes de salida (227,227,3).
    imageDataStoreForValidation, ... % DataStore original.
    'ColorPreprocessing', 'gray2rgb' ... % Pasar de grises a rgb.
);

% Especificamos las opciones de entrenamiento de AlexNet. 
options = trainingOptions( ...
    'sgdm', ... % Se emplea: Stochastic Gradient Descent with Momentum.
    'MiniBatchSize', 10, ... % Tamaño de los lotes de imágenes que circulan por la red.
    'MaxEpochs', 10, ... % Número de ciclos de entrenamiento, este se compone de un número de iteraciones, siendo una iteración cuando todos los batch han recorrido la red.
    'InitialLearnRate', 1e-4, ... % Factor de aprendizaje.
    'ValidationData', aumentedImageDataStoreForValidation, ... % Set de imágenes para realizar la validación. 
    'ValidationFrequency', 3, ... % Indica cada cuantas iteraciones se realiza el proceso de validación.
    'ValidationPatience', Inf, ... % Cuando ya lleva cierto numero de ciclos de etrenamiento para si no hay mejora, en este caso no para.
    'Verbose', false, ... % No se muestra el progreso del entrenamiento por la consola de comandos.
    'Plots','training-progress' ... % El proceso del entrenamiento se representa con una gráfica de puntos.
);

% Lanza el entrenamiento de AlexNet, requiere el uso de la GPU.
netTransfer = trainNetwork(aumentedImageDataStoreForTraining,layers,options);

% Guarda en el fichero netTransfer el contenido de la variable netTransfer.
save netTransfer netTransfer
