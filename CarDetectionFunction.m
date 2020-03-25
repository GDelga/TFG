function CarDetectionFunction(directory, videoName, panel, recortes, figure, textPanel, stopFunction, resetPanels)

    %% Carga de alexNet e imágenes de entrada

    try
        % Carga alexNet de su fichero en una variable del workspace. 
        load alexNet alexNet;
    catch
        % Se producirá un error si no se encuentra el fichero alexNet.
        uialert(figure,"Can't load the alexNet file\n Please retrain the net", 'Error', 'Icon','error');
        resetPanels();
        return;
    end
    
    % Dimensiones de las imágenes de entrada de alexNet (227 x 227 x 3).
    AlexNetInputSize = alexNet.Layers(1).InputSize;
    
    % Concatenamos la ruta al fichero y el nombre del fichero.
    videoFile = strcat(directory, videoName);
    
    % Objeto para la lectura de los frame de vídeo.
    vidReader = VideoReader(videoFile);

    %{
    Un objeto de flujo óptico permite estimar la direccion, el sentido y la 
    orientación de los objetos en movimiento mediante el uso del método 
    Farneback. Este trabaja con imagenes con una capa (imagenes en escala 
    de grises). Acto seguido reseteamos su estado.
    %}
    opticalFlowMethod = opticalFlowFarneback;  
    reset(opticalFlowMethod);
    
    try 
        % Leemos el primer frame de video. 
        frameRGB = readFrame(vidReader);
        uialert(figure,'Loading video','Success', 'Icon','success');
    catch
        % Se producirá un error si no se puede cargar el vídeo.
        uialert(figure,"Can't load the video", 'Error', 'Icon','error');
        resetPanels();
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
          uialert(figure,'The video has been stopped','Success', 'Icon','success');
          resetPanels();
          return;
      end
      
      % Obtiene el frame de video actual.
      frameRGB = readFrame(vidReader);
        
      % Muestra la imagen en el panel lateral.
      imshow(frameRGB, 'parent', panel);
      drawnow;
      
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
             uialert(figure,'The video has been stopped','Success', 'Icon','success');
             resetPanels();
             return;
          end
          
          % Si la región es la de un posible vehiculo.
          if RegionProperties(region).Area > 500
            
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
            imshow(resizedImage, 'parent', recortes);
            drawnow;

            % Clase con mayor puntuación y puntuaciones para cada clase.
            [className , scores] = classify(alexNet,resizedImage);
            
            % Valor máximo del array, máximo grado de pertenencia.
            maxScore = max(scores);
            
            % Contabilización de vehículos.
            if (className ~= 'Asphalt') && (className ~= 'Lines') && (className ~= 'Wall') && (maxScore >= 0.875)... 
            && RegionProperties(region).Centroid(2) > 600 && RegionProperties(region).Centroid(2) < 614
	            
               switch className
		            case 'Bus'
		              numFrontBus = numFrontBus + 1;
		            case 'TruckVan'
		              numFrontTrack = numFrontTrack + 1;
		            case 'CarAhead'
		              numFrontCar = numFrontCar + 1;
		            case 'CarBehind'
		              numBackCar = numBackCar + 1 ;
		            case 'Motorcycle'
		              numFrontMoto = numFrontMoto + 1;
               end
               
            end
          
            % Clasificamos la imagen si esta es la de un vehículo.
            if (className ~= 'Asphalt') && (className ~= 'Lines') && (className ~= 'Wall') && (maxScore >= 0.875) ... 
            && RegionProperties(region).Centroid(2) > 450 && RegionProperties(region).Centroid(2) < 950 
            
               % Mostramos información en el panel de texto.
               textPanel.Value{end+1} = 'Asphalt --- Bus --- Car ahead --- Car from behind --- Lines --- Motorcycle --- Truck or Van --- Wall';
               textPanel.Value{end+1} = char(join(string(scores)));
               textPanel.Value{end+1} = '';
               
               % Color y nombre asociado a la clase de cada vehículo.
               switch className
                  case 'Bus'
                    color = 'yellow'; 
                    category = ' Bus';
                  case 'TruckVan'
                    color = 'white'; 
                    category = ' Truck or Van';
                  case 'CarAhead'
                    color = 'blue';
                    category = ' Car ahead';
                  case 'CarBehind'
                    color = 'red';
                    category = ' Car from behind';
                  case 'Motorcycle'
                    color = 'green';
                    category = ' Motorcycle';
               end
               
               % Pintamos el recuadro que envuelve el vehículo.
               hold(panel,'on'); 
               text(XSupDcha,YSupDcha,category, 'FontSize',14, 'Color',color, 'FontWeight', 'bold', 'Parent', panel);
               line([XSupIzda,XSupDcha],[YSupIzda,YSupDcha],'LineWidth',3,'Color',color, 'Parent', panel);
               line([XSupIzda,XInfIzda],[YSupIzda,YInfIzda],'LineWidth',3,'Color',color, 'Parent', panel);
               line([XSupDcha,XInfDcha],[YSupDcha,YInfDcha],'LineWidth',3,'Color',color, 'Parent', panel);
               line([XInfIzda,XInfDcha],[YInfIzda,YInfDcha],'LineWidth',3,'Color',color, 'Parent', panel);
               drawnow;
               hold(panel,'off');
               
            end % Fin del IF en el que se muestra información por pantalla.
          
          end % Fin del IF en el que se comprueba el área de la región capturada.
          
      end % Fin del bucle FOR en el que se procesa cada región con movimiento.
      
    end % Fin del bucle WHILE, se ejecutará mientras haya que leer frames.
    
    %% Servidor ThingSpeak
    
    % Subimos a ThingSpeak la información de los contadores.
    channelIDParking = 986255;
    writeAPIKeyParking = 'OSC85NR2M22OOXQG';
    dataField = [numFrontCar,numBackCar,numFrontTrack,numBackTrack,numFrontMoto,numBackMoto,numFrontBus,numBackBus];
    thingSpeakWrite(channelIDParking, dataField, 'Writekey', writeAPIKeyParking);
    
    %% Notificación y reseteo
    
    % Se notifica al usuario que el proceso ha terminado.
    uialert(figure,'The process has ended','Success', 'Icon','success');
    
    % Reseteo de las imágenes de los paneles.
    resetPanels();

end
