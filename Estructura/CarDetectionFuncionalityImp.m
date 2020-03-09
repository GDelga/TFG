classdef CarDetectionFuncionalityImp < CarDetectionFuncionality
    methods
        function runDetection(directory, videoName, panel, recortes, figure, textPanel, stopFunction, resetPanels)
            try
                %{
                Carga la red neuronal del fichero netTransfer en una variable del 
                workspace con el mismo nombre.
                %}
                load netTransfer;
            catch
                uialert(figure,"Can't load the netTransfer file\n Please retrain the net", 'Error', 'Icon','error');
                resetPanels();
                return;
            end
            %{
            Obtenemos las dimensiones de las entradas de la red neuronal,
            imagenes de [ 227 , 227 , 3 ]
            %}
            AlexNetInputSize = netTransfer.Layers(1).InputSize;

            % Concatenamos la ruta al fichero y el nombre del fichero.
            videoFile = strcat(directory, videoName);

            %Leemos el video
            vidReader = VideoReader(videoFile);

            %{
            Crea un objeto de flujo optico, este permitira estimar la direccion,
            sentido de los objetos en movimiento utilizando el metodo Farneback.
            Este trabaja con imagenes con una capa (imagenes en escala de grises).
            Acto seguido reseteamos su estado.
            %}
            opticalFlowMethod = opticalFlowFarneback;  
            reset(opticalFlowMethod);

            try
                %{ 
                Leemos el primer frame de video para obtener informacion sobre estos,
                como el alto, el ancho y el numero de capas que los componen.
                %}
                frameRGB = read(vidReader,1);
                uialert(figure,'Loading video','Success', 'Icon','success');
            catch
                uialert(figure,"Can't load the video", 'Error', 'Icon','error');
                resetPanels();
                return;
            end

            [HeightOfFrame , WidthOfFrame , NumberOfFrameLayers] = size(frameRGB);
            frameRGBprev = frameRGB; 
            frameGrayprev = rgb2gray(frameRGB);

            % Obtenemos el numero total de frames que posee el video.
            NFrames = vidReader.NumberOfFrames;
            numFrontCar = 0;
            numBackCar = 0;
            numFrontTrack = 0;
            numBackTrack = 0;
            numFrontBus = 0;
            numBackBus = 0;
            numFrontMoto = 0;
            numBackMoto = 0;
            start = 50;
            % Carga todo el video, desde el primer al ultimo frame
            for  currentFrameNumber=start:1:NFrames
              stop = stopFunction();
              if stop == 1
                  uialert(figure,'The video has been stopped','Success', 'Icon','success');
                  resetPanels();
                  return;
              end
              % Obtiene el frame de video actual.
              frameRGB = read(vidReader, currentFrameNumber);
              % Estima el flujo optico: Calcula los vectores de movimiento.
              opticalFlow = estimateFlow(opticalFlowMethod,rgb2gray(frameRGB));
              imshow(frameRGB, 'parent', panel);
              hold(panel,'on')
              % Plot the flow vectors
              %plot(flow,'DecimationFactor',[25 25],'ScaleFactor', 2, 'Parent',panel);
              %line([0,N],[600,610],'LineWidth',3,'Color','#7E2F8E', 'Parent', panel);
              drawnow
              hold(panel,'off')
              drawnow

              if currentFrameNumber > 2
                MagnitudFlow = mat2gray(opticalFlow.Magnitude);
                OrientacionFlow = opticalFlow.Orientation;
                %{
                mean2: Calcula la media de los valores de una matriz.
                std2: Calcula la desviacion estandar de los elementos de una matriz.
                Recordemos que la desviacion estandar es un concepto asociado a la
                dispersion, nos dice cuanto se aleja un valor de la media.
                %}
                level = mean2(MagnitudFlow)+std2(MagnitudFlow);
                BWMagFlow = MagnitudFlow > level;
                %Devuelve las etiquetas detectadas
                [Labels,Nlabels] = bwlabel(BWMagFlow);
                %figure(3); imagesc(Labels); impixelinfo; colorbar
                %Devuelve el area del objeto detectadao en la imagen
                RProp   = regionprops(Labels,'all');
                RPropOrientacion  = regionprops(Labels,OrientacionFlow,'all');

                amp = 0;
                %Nos recorremos todas las etiquetas
                for h=1:1:Nlabels
                  stop = stopFunction();
                  if stop == 1
                     uialert(figure,'The video has been stopped','Success', 'Icon','success');
                     resetPanels();
                     return;
                  end
                  % Si el area es la de un posible vehiculo.
                  if RProp(h).Area > 500
                    % Obtenemos la coordenada X superior izquierda.
                    XSupIzda =  round(RProp(h).BoundingBox(1)+amp);
                    if XSupIzda <=0; XSupIzda = 1; end
                    % Obtenemos la coordenada Y superior izquierda.
                    YSupIzda =  round(RProp(h).BoundingBox(2)+amp);  
                    if YSupIzda <=0; YSupIzda = 1; end
                    % Obtenemos la coordenada X superior derecha.
                    XSupDcha =  round(XSupIzda + RProp(h).BoundingBox(3) + amp);
                    if XSupDcha > WidthOfFrame; XSupDcha = WidthOfFrame; end
                    % Obtenemos la coordenada Y superior derecha.
                    YSupDcha =  YSupIzda;
                    % Obtenemos la coordenada X inferior izquierda.
                    XInfIzda =  XSupIzda;
                    % Obtenemos la coordena Y inferior izquierda.
                    YInfIzda =  round(YSupIzda + RProp(h).BoundingBox(4) + amp);
                    if YInfIzda > HeightOfFrame; YInfIzda = HeightOfFrame; end
                    % Obtenemos la coordenada X inferior derecha.
                    XInfDcha =  XSupDcha;
                    % Obtenemos la coordenada Y inferior derecha.
                    YInfDcha =  YInfIzda;

                    %Extraemos la imagen correspondiente detectada en el frame actual
                    Recorte = frameRGB(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);
                    %{
                    Redimensionamos la imagen para poder pasarsela a la red
                    neuronal y asi realizar su clasificacion.
                    %}
                    Resized = imresize(Recorte, AlexNetInputSize(1:2), 'bilinear');       
                    imshow(Resized, 'parent', recortes);drawnow

                    %% Clasifcaci�n propiamente dicha
                    %label son las etiquetas identificadas
                    %Error es el nombre que define la proporcion de similitud
                    [label, Error]  = classify(netTransfer,Resized);
                    [MEt,MaxEt] = max(Error);

                    %linea para contar los coches!!!!!!!!
                    if (label ~= 'Asfalto') && (label ~= 'Lineas') && (label ~= 'Muro')... 
                      && (MEt >= 0.5)... 
                      && RPropOrientacion(h).Centroid(2) > 600 && RPropOrientacion(h).Centroid(2) < 614
                        switch label
                            case 'Bus'
                              numFrontBus = numFrontBus + 1;
                            case 'CamionFurgo'
                              numFrontTrack = numFrontTrack + 1;
                            case 'CocheDelantera'
                              numFrontCar = numFrontCar + 1;
                            case 'CocheTrasera'
                              numBackCar = numBackCar + 1 ;
                            case 'Moto'
                              numFrontMoto = numFrontMoto + 1;
                        end
                    end

                    %Clasificamos el label
                    if (label ~= 'Asfalto') && (label ~= 'Lineas') && (label ~= 'Muro')... 
                     && (MEt >= 0.5)... 
                     && RPropOrientacion(h).Centroid(2) > 450 && RPropOrientacion(h).Centroid(2) < 950 
                    %Mostramos informaci�n en el pabel de texto
                       textPanel.Value{end+1} = strcat(char(label), ': ');
                       textPanel.Value{end+1} = char(join(string(Error)));
                       switch label
                          case 'Bus'
                            color = 'yellow'; texto = ' Front Bus';
                          case 'CamionFurgo'
                            color = 'white'; texto = ' Front Truck';
                          case 'CocheDelantera'
                            color = 'blue'; texto = ' Front Car';
                          case 'CocheTrasera'
                            color = 'red'; texto = ' Back Car';
                          case 'Moto'
                            color = 'green'; texto = ' Front Moto';
                       end
                       %Pintamos el recuadro
                       hold(panel,'on'); text(XSupDcha,YSupDcha,texto, 'FontSize',14, 'Color',color, 'FontWeight', 'bold', 'Parent', panel);
                       line([XSupIzda,XSupDcha],[YSupIzda,YSupDcha],'LineWidth',3,'Color',color, 'Parent', panel);
                       line([XSupIzda,XInfIzda],[YSupIzda,YInfIzda],'LineWidth',3,'Color',color, 'Parent', panel);
                       line([XSupDcha,XInfDcha],[YSupDcha,YInfDcha],'LineWidth',3,'Color',color, 'Parent', panel);
                       line([XInfIzda,XInfDcha],[YInfIzda,YInfDcha],'LineWidth',3,'Color',color, 'Parent', panel);
                       hold(panel,'off');
                       drawnow
                  end
                 end
                end
              end
            end
            %Llamada a ThingSpeak para guardar contadores
            channelIDParking = 986255;
            dataField = [numFrontCar,numBackCar,numFrontTrack,numBackTrack,numFrontMoto,numBackMoto,numFrontBus,numBackBus];
            writeAPIKeyParking = 'OSC85NR2M22OOXQG';
            thingSpeakWrite(channelIDParking, dataField, 'Writekey', writeAPIKeyParking);
            uialert(figure,'The process has ended','Success', 'Icon','success');
            resetPanels();
        end
    end
end
