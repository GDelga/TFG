% Borrar todas las variables del espacio de trabajo.
clear;

% Cierra todos los gráficos que se estén mostrando.
close all;

% Almacén de imágenes, toma la estructura de las carpetas y subcarpetas.
imds = imageDatastore('Vehiculos','IncludeSubfolders',true,'LabelSource','foldernames');

% Divide el imageDataStore en dos imageDataStore (90%,10%).
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.9,'randomized');



%{
% Numero de imagenes totales que vamos a usar en el entrenamiento.
numTrainImages = numel(imdsTrain.Labels);

% Seleccion aleatoria de k elementos unicos que están entre 1 y N.
idx = randperm(numTrainImages,64);

%% Ventana de ejemplo

figure('Name','64 imagenes al azar del conjunto de entrenamiento');

for i = 1:64
    
    % Prepara el contenedor de la imagen i-ésima.
    subplot(8,8,i);
    
    % Carga la imagen i-ésima.
    I = readimage(imdsTrain,idx(i));
    
    % Muestra la imagen i-ésima.
    imshow(I);

end
%}

%% Carga y readaptaptación de la red neuronal AlexNet

% Carga la red neuronal AlexNet en la variable net.
net = alexnet;

% Extraemos las capas de la red neuronal en una variable.
networkLayers = net.Layers;

% Extraemos la priemra capa de la red neuronal en una variable.
firstLayer = networkLayers(1);

% Extraemos el tamaño de la entrada de la primera capa.
inputSize = firstLayer.InputSize;

% Extracción de las N - 3 capas de la red neuronal. 
layersTransfer = net.Layers(1:end-3);

% Obtenemos el número de clases del problema de clasificación.
numClasses = numel(categories(imdsTrain.Labels));

%{
Construimos una nueva red neuronal a partir de la anterior, esta se
podrá adaptar para trabajar con el neuvo problema de clasificación.
%}
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20) % No tiene mas que 2D
    softmaxLayer % Se ocupa de obtener las probabilidades a nivel de clasificación.
    classificationLayer % Recive la probabilidad de cada clase.
];

%% Entrenamiento de la red neuronal
%{
La red requiere trabajar con imagenes de tamaño 227x227x3. 
Las imagenes de los dataStore normalmente son de tamaño diferente, por
ello existe objeto imageDataAugmenter nos ayudara en esta tarea.
%} 

%{

% Añade nuevas imagenes "distosionadas/fake" de las originales. Aumenta el
numero de imagenes de entrenamiento.

imageDataAugmenter permite definir un conjunto de opciones para el
procesamiento de imagenes, entre ellas se encuentra el redimensionado,
la rotación, la reflexión, etc.

Valores:

    * ('RandXReflection',true): Reflexión aleatoria en la dirección izquierda-derecha.
                                Cuando es true, cada imagen es es relejada horizontalmente con un 50% de probabilidad.

    * ('RandXTranslation',pixelRange): Rango para la translación horizontal. La medida está en píxeles.
    * ('RandYTranslation',pixelRange): Rango para la translación vertical. La medida está en píxeles.
%}
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandXTranslation',pixelRange,'RandYTranslation',pixelRange);

%{
augmentedImageDatastore transforma un conjunto de imagenes 
(para entrenamiento, validacion, testing, predicción, etc) especificando
las opciones de su tratamiento (redimensionado, rotacion, reflexión, etc).
De esta forma podemos redimensionar las imagenes para hacerlas compatibles
con el tamaño de entrada de nuestra red neuronal.
%}

% A partir de los ratos obtenemos un modelo con una funcion

%{
Aumentar la información de las imágenes de entrenamiento con operaciones de 
preprocesamiento aleatorias es bueno, sirve para prevenir el sobreajustamiento
(Overfitting) y que la red tenga que memorizar los detalles exactos de las
imágenes de entrenamiento.

Overfitting: Este concepto indica que la red neuronal aprende mucho sobre 
los datos de entrenamiento pero tiene un desempeño pobre en los datos de
validación o en datos que nunca ha visto.

%}
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain,'DataAugmentation',imageAugmenter);

%{
To automatically resize the validation images without performing further data augmentation, 
use an augmented image datastore without specifying any additional preprocessing operations.
%}
% Imagenes Entrenamiento crea los pesos de la red.
% Imagenes validacion Verifica si la clasificacion es correcta, si falla e
% exceso el entrenamient esta mal y se necesita aumentar el conjuto de
% datos de entrada.
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%{
Especificamos las opciones del entrenamiento con imagenes. 

Para realizar la transferencia de aprendizaje, mantenemos tal cual las 
capas de la red neuronal preentrenada.

Para ralentizar el aprendizaje en las capas transferidas (capas antiguas), 
establecer el rango de aprendizaje en un valor pequeño. 

Recuerda que en el paso anterior incrementamos el factor de aprendizaje de
la capa completamente conectada para acelerar el aprendizaje de las últimas
capas de la red neuronal.

Esta configuración permitirá un aprendizaje más rápido en las nuevas
capas, por el contrario, este será más lento en las capas antiguas.

Para realizar el reaprendizaje/reentrenamiento no se necesita entrenar la
red neuronal con muchos epochs (ciclos de entrenamiento). En cada ciclo 
todos los datos de entrenamiento pasan por la red neuronal para que esta
pueda aprender de ellos.

El parametro Batch Size (tamaño del lote) permite indicar el número de datos
con los que se trabaja en una iteración, entendiendo como iteraciones el
total de ejecuciones necesarias para completar el ciclo de entrenamiento.

El Validation Set es un conjunto de datos para probar la red neuronal
con datos con los que esta no ha trabajado.

Para validar la red a intervalos regulares durante el entrenamiento
especifican los datos de validación y el valor de 'ValidationFrequency' 
para que la red se valide un numero de veces cada ciclo de entrenamiento.

%}

options = trainingOptions( ...
    'sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData', augimdsValidation, ... 
    'ValidationFrequency',3, ... % Cada cierto n de imagenes realiza el test de validacion
    'ValidationPatience',Inf, ... % Cuando ya lleva cierto numero de ciclos de etrenamiento para, en este caso no para.
    'Verbose',false, ...
    'Plots','training-progress' ...
);
% imdsValidation, ...

% Iteracion cuando pasa todos los batch una vez

%{
Vamos a entrenar la red compuesta por las capas antiguas y las nuevas.
Por defecto, la funcion trainNetwork usa una GPU si es que hay alguna 
disponible (requiere el paquete Parallel Computing Toolbox y el paquete 
CUDA permite usar GPU'S con capacidad del calculo 3.0 o superior), de lo 
contrario usa una CPU.
%}
netTransfer = trainNetwork(augimdsTrain,layers,options); % imdsTrain

% Guarda en el fichero netTransfer el contenido de la variable netTransfer.
save netTransfer netTransfer

%% Clasificacion de imagenes.

%{
Dada una red neuronal y un dataStore, solicitamos su clasificacion.

La función de clasificación proporciona:
    
    + La clase a la que la red asigna la puntuación más alta. 
    
    + La puntacion otorgada a la imagen con respecto a cada clase (Fuzzy).

        * YPred es un vector categorico de 1xN (N: observaciones o imagenes)
          que contiene la clase a la que pertenece cada imagen.

        * socres es un objeto "cell array", este tiene en cada posicion una
          matriz NxK, para N numero de observaciones y para K numero de clases.

%}
[YPred,scores] = classify(netTransfer,imdsValidation);

%{
randperm(n,k) devuelve un vector que contiene k elementos unicos 
enteros seleccionados de forma aleatoria entre 1 y n incluidos.

numel(n) devuelve el numero de elementos de un array
%}
idx = randperm(numel(imdsValidation.Files),6);

% Lanza una ventana grafica (GUI) con las propiedades por defecto.
figure('Name','Clasificacion de 6 imagenes del conjunto de validacion');

for i = 1:6
    
    %{
    subplot(M,N,P)
    Divide la ventana en M x N subventanas y coloca el grafico
    correspondiente en la P-esima ventana (Distribución: UP-LEFT --> DOWN-RIGHT)
    %}
    subplot(3,2,i)
    
    % Leer una imagen de un dataStore especificando su indice.
    I = readimage(imdsValidation,idx(i));
    
    % Mostrar un imagen almacenada en una variable.
    imshow(I)
   
    % label contiene el nombre de la clase a la que pertenece la clase.
    label = YPred(idx(i));
    
    % Convierte la variable en un string para establecer el titulo.
    title(string(label));

end

%% Visualización de los pesos

% Obtiene los pesos para la segunda capa de la red neuronal convolucional (CNN).
w1 = netTransfer.Layers(2).Weights;

% Pasa la imagen a escala de grises.
w1 = mat2gray(w1);

%{ 
Redimensiona la imagen.

Valores:

    * La imagen a redimensionar.
    * Factor de escalado (Mayor que 1 si la imagen va a ser más grande
      que la imagen de entrada, menor que 1 si la imagen va a ser más
      pequeña que la imagen de entrada).

%}
w1 = imresize(w1,5);

% Crea una ventana.
figure('Name','Pesos de la capa 2 de la red neuronal');

% Muestra un montage en imagenes de los pesos de la segunda capa.
montage(w1);
