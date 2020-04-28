classdef ASSmartCities
    methods
        function r = retraining(obj, tConfigData)
            
            %% Carga y división de los set de imágenes.   
            try
                % Almacén de imágenes, toma la estructura de las carpetas y subcarpetas.
                vehicleImageDataStore = imageDatastore('ImageCategories','IncludeSubfolders', true,'LabelSource','foldernames');
            catch
                % Se producirá un error si no se encuentra el fichero alexNet.
                r = "ImageCategories direcctory not exists";
                return;
            end

            % Divide el imageDatastore en dos imageDatastore con un reparto aleatorio de imágenes (80%,20%).
            [imageDataStoreForTraining , imageDataStoreForValidation] = splitEachLabel(vehicleImageDataStore,0.8,'randomized');

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
                'WeightLearnRateFactor', tConfigData.getWeightLearnRateFactor(), ... % ThisLayerLearnFactor = ParamValue *  InitialLearnRateOfNetwork
                'BiasLearnRateFactor', tConfigData.getBiasLearnRateFactor() ... % ThisLayerBiasFactor = ParamValue * InitialLearnRateOfNetwork
            );

            %{
            classificationLayer:

            Esta capa recibe la probabilidad de pertenencia de una imagen a cada clase 
            del problema de clasificación, tomando como la clase a la que pertenece 
            dicha imagen como aquella en la que ha obtenido una mayor probabilidad.

            MATLAB detectará automáticamente las clases del problema de clasificación.
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
                'RandXReflection', true, ... % Reflexión de izquierda a derecha, 50%.
                'RandRotation', [-40 40], ... % Rango de la rotación en grados.
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
                'ColorPreprocessing', 'gray2rgb' ... % Pasar de color a escala de grises.
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
                'ColorPreprocessing', 'gray2rgb' ... % Pasar de color a escala de grises.
            );

            %% Entrenamiento de la red neuronal.
            % Aquí la red aprenderá a extraer las características de las imágenes.

            % Especificamos las opciones de entrenamiento de AlexNet. 
            options = trainingOptions( ...
                tConfigData.getSolverMethod(), ... % Se emplea: Stochastic Gradient Descent with Momentum.
                'MiniBatchSize', tConfigData.getMiniBatchSize(), ... % Tamaño de los lotes de imágenes que circulan por la red.
                'MaxEpochs', tConfigData.getMaxEpochs(), ... % Número de ciclos de entrenamiento, este se compone de un número de iteraciones, siendo una iteración cuando todos los batch han recorrido la red.
                'InitialLearnRate', tConfigData.getInitialLearnRate(), ... % Factor de aprendizaje.
                'ValidationData', aumentedImageDataStoreForValidation, ... % Set de imágenes para realizar la validación.
                'ValidationFrequency', tConfigData.getValidationFrequency(), ... % Indica cada cuantas iteraciones se realiza el proceso de validación.
                'ValidationPatience', tConfigData.getValidationPatience(), ... % Cuando ya lleva cierto numero de ciclos de etrenamiento para si no hay mejora el entrenamiento se detiene.
                'Shuffle', 'every-epoch', ... % Baraja las imagenes de entrenamiento al comenzar cada Epoch y las de validación antes de comenzar cada test.
                'LearnRateSchedule', 'piecewise', ... % Activa el planificador del de aprendizaje.
                'LearnRateDropFactor', tConfigData.getLearnRateDropFactor(), ... % Número a multiplicar por el factor de aprendizaje para modificarlo en el tiempo.
                'LearnRateDropPeriod', tConfigData.getLearnRateDropPeriod(), ... % Número de ciclos de entrenamiento que han de pasar hasta volver modificar el factor de aprendizaje.
                'Verbose', false, ... % No se muestra el progreso del entrenamiento por la consola de comandos.
                'Plots', 'training-progress' ... % El proceso del entrenamiento se representa con una gráfica de puntos.
            );

            % Lanza el entrenamiento de AlexNet, requiere el uso de la GPU, en el peor caso se usará la CPU.
            alexNet = trainNetwork(aumentedImageDataStoreForTraining, networkLayers, options);

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
            analyzeNetwork(alexNet);

            %% Matriz de confusión.

            % Clase que ha asignado AlexNet a cada imagen del set de vehículos.
            predictedLabels = classify(alexNet, vehicleImageDataStore);

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
                'FontSize', 8, ... % Tamaño de la fuente.
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
            save alexNet alexNet
            r = NaN;
        end
        
        function r = detection(obj, tCarDetection)           
            %% Carga de alexNet e inicialización del lector de vídeo
            stopFunction = tCarDetection.getIsStop();
            try
                % Carga alexNet de su fichero en una variable del workspace. 
                load alexNet alexNet;
            catch
                % Se producirá un error si no se encuentra el fichero alexNet.
                r = "Can't load the alexNet file\n Please retrain the net";
                return;
            end

            % Dimensiones de las imágenes de entrada de alexNet (227 x 227 x 3).
            AlexNetInputSize = alexNet.Layers(1).InputSize;

            % Concatenamos la ruta al fichero y el nombre del fichero.
            videoFile = strcat(tCarDetection.getDirectory(), tCarDetection.getVideoName());

            % Objeto para la lectura de los frame de vídeo.
            vidReader = VideoReader(videoFile);

            %{
            Un objeto de flujo óptico permite estimar la direccion, el sentido y la 
            orientación de los objetos en movimiento, en este caso, mediante el uso
            del método de Farneback. Este trabaja con imagenes con una capa (imagenes
            en escala de grises). Acto seguido reseteamos su estado.
            %}
            opticalFlowMethod = opticalFlowFarneback;  
            reset(opticalFlowMethod);

            try 
                % Leemos el primer frame de video.
                frameRGB = readFrame(vidReader);
                Controler.getInstance().execute(Context(Events.CAR_DETECTION_VIDEO_LOADED, 'Loading video'));
            catch
                % Se producirá un error si no se puede cargar el vídeo.
                r = "Can't load the video";
                return;
            end

            % Alto, ancho y número de capas que componen una imagen en color.
            [HeightOfFrame , WidthOfFrame , ~] = size(frameRGB);

            % Variables para el conteo del tráfico.
            numBackCar = 0;
            numFrontCar = 0;
            numBackBus = 0;
            numFrontBus = 0;
            numBackMoto = 0;
            numFrontMoto = 0;
            numBackTrack = 0;
            numFrontTrack = 0;

            % Reproduce todo el video, desde el frame 2 hasta el n-ésimo.
            while hasFrame(vidReader)  
              % Si el usuario decide parar el video.
              stop = stopFunction();
              if stop == 1
                  r = 1;
                  return;
              end

              % Obtiene el frame de video actual.
              frameRGB = readFrame(vidReader);

              % Muestra la imagen en el panel lateral.
              tVideoData = TVideoData(frameRGB, NaN, NaN, NaN);
              Controler.getInstance().execute(Context(Events.UPDATE_CAR_DETECTION_VIDEO_DATA, tVideoData)); 

              %% Visión por Computador

              % Cálculo del flujo optico: Magnitud, dirección y sentido vectorial.
              opticalFlow = estimateFlow(opticalFlowMethod,rgb2gray(frameRGB));

              %{
              Matriz donde valor es el módulo del vector a partir de ese punto, es 
              decir, la cantidad de movimiento que se ha producido en ese punto.
              %}
              magnitudeFlow = mat2gray(opticalFlow.Magnitude);

              % Media de la cantidad de movimiento.
              magnitudeFlowMean = mean2(magnitudeFlow);

              % Desviación estándar del movimiento.
              magnitudeFlowStandarDesviation = std2(magnitudeFlow);

              % Umbral para filtrar el movimiento que se ha producido en la imagen.
              level = magnitudeFlowMean + magnitudeFlowStandarDesviation;

              %{
              BinaryFlow: Imagen binaria en la cual un pixel es negro si no pasa el
              umbral level y blanco en caso contrario. Estos píxeles blancos son
              aquellos en los que ha habido un nivel de movimiento notable.
              %}
              binaryFlow = magnitudeFlow > level;

              % Total de regiones con movimiento que se han detectado.
              [~ , numberOfDetectedRegions] = bwlabel(binaryFlow);

              % Calcula las propiedades: Centroide, coordenadas y área de las regiones.
              RegionProperties = regionprops(binaryFlow);

              %% Conteo del tráfico y visualización de la información

              % Nos recorremos todas las etiquetas
              for region = 1:1:numberOfDetectedRegions

                  % Si el usuario decide parar el video.
                  stop = stopFunction();
                  if stop == 1
                     r = 1;
                     return;
                  end

                  % Si la región es la de un posible vehiculo.
                  if RegionProperties(region).Area >= 200

                    % Obtenemos la coordenada X superior izquierda.
                    XSupIzda =  round(RegionProperties(region).BoundingBox(1));
                    if XSupIzda <= 0; XSupIzda = 1; end
                    % Obtenemos la coordenada Y superior izquierda.
                    YSupIzda =  round(RegionProperties(region).BoundingBox(2));  
                    if YSupIzda <= 0; YSupIzda = 1; end
                    % Obtenemos la coordenada X superior derecha.
                    XSupDcha =  round(XSupIzda + RegionProperties(region).BoundingBox(3));
                    if XSupDcha > WidthOfFrame; XSupDcha = WidthOfFrame; end
                    % Obtenemos la coordenada Y superior derecha.
                    YSupDcha =  YSupIzda;
                    % Obtenemos la coordenada X inferior izquierda.
                    XInfIzda =  XSupIzda;
                    % Obtenemos la coordena Y inferior izquierda.
                    YInfIzda =  round(YSupIzda + RegionProperties(region).BoundingBox(4));
                    if YInfIzda > HeightOfFrame; YInfIzda = HeightOfFrame; end
                    % Obtenemos la coordenada X inferior derecha.
                    XInfDcha =  XSupDcha;
                    % Obtenemos la coordenada Y inferior derecha.
                    YInfDcha =  YInfIzda;

                    % Extraemos la imagen detectada en el frame actual.
                    extractedImage = frameRGB(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);

                    % Redimensionamos la imagen y la mostramos en el panel lateral.
                    resizedImage = imresize(extractedImage, AlexNetInputSize(1:2), 'bilinear');
                    tVideoData = TVideoData(NaN, resizedImage, NaN, NaN);
                    Controler.getInstance().execute(Context(Events.UPDATE_CAR_DETECTION_VIDEO_DATA, tVideoData));

                    % Clase con mayor puntuación y puntuaciones para cada clase.
                    [className , scores] = classify(alexNet,resizedImage);

                    % Valor máximo del array, máximo grado de pertenencia.
                    maxScore = max(scores);

                    % Contabilización de vehículos.
                    if (className ~= 'Asphalt') && (className ~= 'Wall') && (maxScore >= 0.50)... 
                    && RegionProperties(region).Centroid(2) > 592 && RegionProperties(region).Centroid(2) < 603

                       switch className
                            case 'FrontBus'
                              numFrontBus = numFrontBus + 1;
                            case 'BackBus'
                              numBackBus = numBackBus + 1;
                            case 'FrontTruckVan'
                              numFrontTrack = numFrontTrack + 1;
                            case 'BackTruckVan'
                              numBackTrack = numBackTrack + 1;
                            case 'FrontCar'
                              numFrontCar = numFrontCar + 1;
                            case 'BackCar'
                              numBackCar = numBackCar + 1 ;
                            case 'FrontMotorbike'
                              numFrontMoto = numFrontMoto + 1;
                            case 'BackMotorbike'
                              numBackMoto = numBackMoto + 1;
                       end

                    end

                    % Clasificamos la imagen si esta es la de un vehículo.
                    if (className ~= 'Asphalt') && (className ~= 'Wall') && (maxScore >= 0.50) ... 
                    && RegionProperties(region).Centroid(2) > 500 && RegionProperties(region).Centroid(2) < 1000 

                       % Color y nombre asociado a la clase de cada vehículo.
                       switch className
                            case 'FrontBus'
                                color = 'yellow'; 
                                category = ' Front Bus';
                            case 'BackBus'
                                color = 'yellow'; 
                                category = ' Back Bus';
                            case 'FrontTruckVan'
                                color = 'white'; 
                                category = ' Front TruckVan';
                            case 'BackTruckVan'
                                color = 'white'; 
                                category = ' Back TruckVan';
                            case 'FrontCar'
                                color = 'blue';
                                category = ' Front Car';
                            case 'BackCar'
                                color = 'blue';
                                category = ' Back Car';
                            case 'FrontMotorbike'
                                color = 'green';
                                category = ' Front Motorbike';
                            case 'BackMotorbike'
                                color = 'green';
                                category = ' Back Motorbike';
                       end
                       
                       text = { char(join(string(scores))) , char(className) };
                       % Pintamos el recuadro que envuelve el vehículo.
                       tCarDetectionData = TCarDetectionData(XSupIzda, XSupDcha, XInfIzda, XInfDcha,...
                                YSupIzda, YSupDcha, YInfIzda, YInfDcha, category, color);
                       tVideoData = TVideoData(NaN, NaN, text, tCarDetectionData);
                       Controler.getInstance().execute(Context(Events.UPDATE_CAR_DETECTION_VIDEO_DATA, tVideoData));
                    end % Fin del IF en el que se muestra información por pantalla.

                  end % Fin del IF en el que se comprueba el área de la región capturada.

              end % Fin del bucle FOR en el que se procesa cada región con movimiento.

            end % Fin del bucle WHILE, se ejecutará mientras haya que leer frames.

            %% Servidor ThingSpeak

            % Subimos a ThingSpeak la información de los contadores.
            channelIDParking = 986255;
            writeAPIKeyParking = 'OSC85NR2M22OOXQG';
            dataField = [numFrontCar,numBackCar,numFrontTrack,numBackTrack,numFrontMoto,numBackMoto,numFrontBus,numBackBus];
            %thingSpeakWrite(channelIDParking, dataField, 'Writekey', writeAPIKeyParking);

            r = NaN;
        end
    end
end