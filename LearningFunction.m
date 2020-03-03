function LearningFunction(configData)

%% Carga y división de los set de imágenes.

% Almacén de imágenes, toma la estructura de las carpetas y subcarpetas.
vehicleImageDataStore = imageDatastore('Vehiculos','IncludeSubfolders', true,'LabelSource','foldernames');

% Divide el imageDatastore en dos imageDatastore con un reparto aleatorio de imágenes (90%,10%).
[imageDataStoreForTraining , imageDataStoreForValidation] = splitEachLabel(vehicleImageDataStore,0.9,'randomized');

%% Carga y extracción de características AlexNet.

% Cargamos la red neuronal AlexNet.
network = alexnet;

% Extraemos las capas de la red neuronal.
networkLayers = network.Layers;

% Extraemos el tamaño de los valores de entrada: Imágenes de (227,227,3).
inputSize = networkLayers(1).InputSize;

% Obtenemos el número de clases del nuevo problema de clasificación.
numClasses = numel(categories(imageDataStoreForTraining.Labels));

%% Transferencia de aprendizaje.
%{
Para readaptar la red neuronal AlexNet a nuestro propio problema de 
clasificación optamos por aplicar la técnica conocida como transferencia
de aprendizaje, esta permite conservar los núcleos de convolución de la
AlexNet original y readaptarlos ligeramente con entrenamiento para que
sirvan para extraer las características de las imágenes del nuevo problema.

En principio conservaremos el estado original de las capas 1 - 22 y 24 las 
cuales ya tienen un aprendizaje inicial y solamente necesitan un bajo valor 
del factor de aprendizaje para readaptarse al nuevo problema de 
clasificación, esto se logrará mediante entrenamiento.
%}

%{
fullyConnectedLayer: 

Esta capa aplica un modelo de lineal a las características extraidas de una
imagen para deducir el grado de pertenencia sin normalizar a una clase del
problema de clasificación. Sus factores de aprendizaje y se calculan en 
función del factor de aprendizaje general de la red.
%}
networkLayers(23) = fullyConnectedLayer( ...
    numClasses, ... % Tenemos que tener tantas neuronas en esta capa como número clases tenga el nuevo problema de clasificación.
    'WeightLearnRateFactor', configData.WeightLearnRateFactor, ... % ThisLayerLearnFactor = ParamValue *  InitialLearnRateOfNetwork
    'BiasLearnRateFactor', configData.BiasLearnRateFactor ... % ThisLayerBiasFactor = ParamValue * InitialLearnRateOfNetwork
);

%{
classificationLayer:

Esta capa recibe la probabilidad de pertenencia de una imagen a cada clase 
del problema de clasificación, tomando como la clase a la que pertenece 
dicha imagen como aquella en la que ha obtenido una mayor probabilidad.

MATLAB detectará automáticamente la clase del problema de clasificación a
la que pertene cada imagen.
%}
networkLayers(25) = classificationLayer;

%% Preprocesamiento de imágenes.

%{
Este proceso sirve para añadir nuevas imagenes a un set, estas son imágenes
distosionadas de las originales, de esta forma tendremos más imagenes para
el entrenamiento y la clasificación. Es una buena práctica, ya que aumenta
la cantidad de información que la red puede aprender de cada clase.
%}

%{
imageDataAugmenter permite definir un conjunto de opciones para el
preprocesamiento de imágenes.
%}
imageAugmenter = imageDataAugmenter( ...
    'RandXScale', [0.5 1], ... % Factor de escalado horizontal.
    'RandYScale', [0.5 1], ... % Factor de escalado vertical.
    'RandXReflection', true, ... % Reflexión de arriba a abajo, 50%.
    'RandYReflection', true, ... % Reflexión de izquierda a derecha, 50%.
    'RandRotation', [-360 360], ... % Rango de la rotación en grados.
    'RandXTranslation', [-30 30], ... % Rango de la translación horizontal.
    'RandYTranslation', [-30 30] ... % Rango de la translación vertical.
);

%{
Este set de imágenes se usará para entrenar AlexNet y así esta pueda
autoajustar los pesos de los núcleos de convolución las neuronas.
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
    'DataAugmentation', imageAugmenter, ... % Opciones de distorsión.
    'ColorPreprocessing', 'gray2rgb' ... % Pasar de grises a rgb.
);

%% Entrenamiento de la red neuronal.
% Aquí la red aprenderá a extraer las características de las imágenes.

% Especificamos las opciones de entrenamiento de AlexNet. 
options = trainingOptions( ...
    configData.SolverMethod, ... % Se emplea: Stochastic Gradient Descent with Momentum.
    'MiniBatchSize', configData.MiniBatchSize, ... % Tamaño de los lotes de imágenes que circulan por la red.
    'MaxEpochs', configData.MaxEpochs, ... % Número de ciclos de entrenamiento, este se compone de un número de iteraciones, siendo una iteración cuando todos los batch han recorrido la red.
    'InitialLearnRate', configData.InitialLearnRate, ... % Factor de aprendizaje.
    'ValidationData', aumentedImageDataStoreForValidation, ... % Set de imágenes para realizar la validación.
    'ValidationFrequency', configData.ValidationFrequency, ... % Indica cada cuantas iteraciones se realiza el proceso de validación.
    'ValidationPatience', configData.ValidationPatience, ... % Cuando ya lleva cierto numero de ciclos de etrenamiento para si no hay mejora, en este caso no para.
    'Shuffle', 'every-epoch', ... % Baraja las imagenes de entrenamiento al comenzar cada Epoch y las de validación antes de comenzar cada test.
    'Verbose', false, ... % No se muestra el progreso del entrenamiento por la consola de comandos.
    'Plots', 'training-progress' ... % El proceso del entrenamiento se representa con una gráfica de puntos.
);

% Lanza el entrenamiento de AlexNet, requiere el uso de la GPU, en el peor caso se usará la CPU.
netTransfer = trainNetwork(aumentedImageDataStoreForTraining, networkLayers, options);

%% Análisis de la red neuronal.

%{
analyzeNetwork:
    
Analiza la arquitectura de red de Deep Learning especificada.
    
Esta herramienta puede mostrar la siguiente información de la red:
    + Las capas que componen su arquitectura.
    + Las operaciones que se están realizando en cada capa.
    + Los tamaños de las activaciones y los parámetros aprendizaje. 
    
Algunas ayudas que proporciona esta herramienta:
    + Ver si faltan alguna capa.
    + Comprobar que todas las capas estén bien conectadas.
    + Averiguar si la capa de entrada tiene el tamaño correcto.
%}
analyzeNetwork(netTransfer);

h = findobj('Name','analyzeNetwork');

%% Matriz de confusión.

% Clase que ha asignado AlexNet a cada imagen del set de vehículos.
predictedLabels = classify(netTransfer, vehicleImageDataStore);
    
% Precisión en tanto por ciento de las clasificaciones realizadas.
accuracy = nnz(vehicleImageDataStore.Labels == predictedLabels) / numel(vehicleImageDataStore.Labels);
accuracy = accuracy * 100;
accuracy = round(accuracy, 2);
accuracy = num2str(accuracy);
accuracy = strcat(" ", accuracy, " ");
    
% Ventana que va a mostrar la matriz de confusión.
figure( ...
    'NumberTitle', 'off', ... % Desactiva que se vea el número de ventana.
    'Name', 'Confusion Matrix', ... % Nombre de la ventana. 
    'Resize', 'off', ... % La ventana no es redimensionable.
    'Units', 'normalized', ... % Unidades de medida ajustadas a la pantalla.
    'OuterPosition', [0,0,1,1] ... % Left, Bottom, Width, Height in %.
);

% Gráfico de las equivocaciones y aciertos que ha tenido AlexNet al clasificar todas las imágenes.
confusionchart( ...
    vehicleImageDataStore.Labels, predictedLabels, ... 
    'Title', strcat('Accuracy of', accuracy, '%'), ... % Título del gráfico.
    'XLabel', 'Predicted Class', ... % Título de los valores en X.
    'YLabel', 'Real Class', ... % Título de los valores en Y.
    'DiagonalColor', 'blue', ... % Colores de los aciertos.
    'OffDiagonalColor', 'red', ... % Colores de los fallos.
    'FontColor', 'black', ... % Color de la fuente.
    'FontSize', 10, ... % Tamaño de la fuente.
    'RowSummary', 'row-normalized', ...% Porcentaje de acierto y error al asignar la clase a la que pertenece la imagen.
    'ColumnSummary', 'column-normalized' ... % Porcentaje de acierto y error al predecir una clase para una imagen.
);

%{
gcf: Obtiene un manipulador de la figura actual.
Menu -> none: No se mostrará el menú superior que viene por defecto.
Toolbar -> none: No se mostrará la barra de herramientas que viene por defecto.
%}
set(gcf, 'Toolbar', 'none', 'Menu', 'none');

%% Guardamos la nueva AlexNet reentrenada en un fichero.
% Guarda en el fichero netTransfer el contenido de la variable netTransfer.
save netTransfer netTransfer

end
