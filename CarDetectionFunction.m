function CarDetectionFunction(directory, videoName, panel, recortes)

    load netTransfer
    sz = netTransfer.Layers(1).InputSize;

    NombreVideo = strcat(directory, videoName);

    vidReader = VideoReader(NombreVideo);

    opticFlow = opticalFlowFarneback;
    %opticFlow = opticalFlowLK;
    reset(opticFlow);

    frameRGB = read(vidReader,1);
    [M,N,s] = size(frameRGB);
    frameRGBprev = frameRGB; 
    frameGrayprev = rgb2gray(frameRGB);

    NFrames = vidReader.NumberOfFrames;
    %% Estimate Optical Flow of each frame
    start = 600;
    for i=start:1:NFrames %despreciamos el 
      %while hasFrame(vidReader)
      frameRGB = read(vidReader,i);
      %frameRGBcopia = frameRGB;
      %frameRGB = readFrame(vidReader);
      frameGray = rgb2gray(frameRGB);
      flow = estimateFlow(opticFlow,frameGray);
      imshow(frameRGB, 'parent', panel);
      hold(panel,'on')
      % Plot the flow vectors
      plot(flow,'DecimationFactor',[25 25],'ScaleFactor', 2, 'Parent',panel);
      
      
      line(panel,[800,800],[550,555],'LineWidth',3,'Color','orange');
            
      
     
      hold(panel,'off')
      drawnow

      if i > 2
        MagnitudFlow    = mat2gray(flow.Magnitude);
        OrientacionFlow = flow.Orientation;
        level = mean2(MagnitudFlow)+std2(MagnitudFlow);
        BWMagFlow = MagnitudFlow > level;

        [Labels,Nlabels] = bwlabel(BWMagFlow);
        %figure(3); imagesc(Labels); impixelinfo; colorbar
        RProp   = regionprops(Labels,'all');
        RPropRed   = regionprops(Labels,frameRGB(:,:,1),'all');
        RPropGreen = regionprops(Labels,frameRGB(:,:,2),'all');
        RPropBlue  = regionprops(Labels,frameRGB(:,:,3),'all');
        RPropOrientacion  = regionprops(Labels,OrientacionFlow,'all');
        
        amp = 0;
        for h=1:1:Nlabels
          if RProp(h).Area > 500
            XSupIzda =  round(RProp(h).BoundingBox(1)+amp);
          if XSupIzda <=0; XSupIzda = 1; end
          YSupIzda =  round(RProp(h).BoundingBox(2)+amp);  
          if YSupIzda <=0; YSupIzda = 1; end

          XSupDcha =  round(XSupIzda + RProp(h).BoundingBox(3) + amp);
          if XSupDcha > N; XSupDcha = N; end
          YSupDcha =  YSupIzda; 

          XInfIzda =  XSupIzda;
          YInfIzda =  round(YSupIzda + RProp(h).BoundingBox(4) + amp);
          if YInfIzda > M; YInfIzda = M; end

          XInfDcha =  XSupDcha; 
          YInfDcha =  YInfIzda;

          Recorte = frameRGB(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);
          RecorteBW = BWMagFlow(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);

          [aar, bbr, ssr] = size(Recorte);
          R = imresize(Recorte, [sz(1) sz(2)], 'bilinear');       
          imshow(R, 'parent', recortes);drawnow

          %% Clasifcaci�n propiamente dicha
          [label, Error]  = classify(netTransfer,R);
          [MEt,MaxEt] = max(Error);
          %disp('Label ='); disp(label) 
          %disp('Error ='); disp(Error)

          % Aqu� debemos tomar una decisi�n para determinar si el coche va en
          % buen sentido o mal. Teniendo en cuenta la posici�n de la c�mara en
          % la carretera. Por la parte izquierda el flujo tendr� una
          % orientaci�n diferente a la derecha. 
          Orientacion = RPropOrientacion(h).MeanIntensity;

          %linea para contar los coches!!!!!!!!
%           if (label ~= 'Asfalto') && (label ~= 'Lineas') && (label ~= 'Muro')... 
%              && (MEt >= 0.5)... 
%              && RPropOrientacion(h).Centroid(2) > 500 && RPropOrientacion(h).Centroid(2) < 550
% %             numCoches +=1;
%           end

          if (label ~= 'Asfalto') && (label ~= 'Lineas') && (label ~= 'Muro')... 
             && (MEt >= 0.5)... 
             && RPropOrientacion(h).Centroid(2) > 500 && RPropOrientacion(h).Centroid(2) < 950 
            %figure(5); bar(Error)
            switch label
            case 'Bus'
              color = 'yellow'; texto = 'Bus';
            case 'CamionFurgo'
              color = 'white'; texto = 'Camion-furgo';
            case 'CocheDelantera'
              color = 'blue'; texto = 'Car Frontal';
            case 'CocheTrasera'
              color = 'red'; texto = 'Car Trasera';
            case 'Moto'
              color = 'green'; texto = 'Moto';
            end

            hold(panel,'on'); text(XSupDcha,YSupDcha,texto, 'Parent', panel);
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
      %PROVISIONALMENTE COMENTADO, NO DESCOMENTAR
      % Create a temporary figure with axes.
% fig = figure;
% fig.Visible = 'off';
% figAxes = axes(fig);
% % Copy all UIAxes children, take over axes limits and aspect ratio.            
% allChildren = panel.XAxis.Parent.Children;
% copyobj(allChildren, figAxes)
% figAxes.XLim = panel.XLim;
% figAxes.YLim = panel.YLim;
% figAxes.ZLim = panel.ZLim;
% figAxes.DataAspectRatio = panel.DataAspectRatio;
% % Save as png and fig files.
% saveas(fig, 'Figura1.bmp');
% savefig(fig, 'Figura1.bmp');
% % Delete the temporary figure.
% delete(fig);
%       frameFigure = imread('Figura1.bmp');
%       if i > start+2
%         writeVideo(videoMPEG,frameFigure);
%       end 
% 
    end
    %Llamada a ThingSpeak para guardar contadores

    close(videoMPEG); %se cierra el video
end
