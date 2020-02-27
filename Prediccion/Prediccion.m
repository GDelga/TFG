%% Parte II: Código a ejecutar en ThingSpeak: estimación usando la funcionalidad de Matlab. 
% Este código se ejecuta en ThingSpeak, donde se realiza la estimación de los parámetros
% En Field2 se almacena (se hace así para evitar accesos de escritura frecuentes al ThingSpeak y para entrar en la ventana de tiempo de ejecución de ThingSpeak) 
% p: orden del modelo
% p+1 parámetros: (c, phi_1, phi_2,...,phi_p)

% Recuperación de los datos de la serie temporal
% Canal Parking: Identificación y claves de acceso
ChannelIDParking = 990311;
readAPIKeyParking = 'OC3B1ZHFICPHHAHE';
writeAPIKeyParking = 'CMC3GUTJC5K5CKIA';

fechaConsulta = '2020/03/01';
field = 0;
%delay(10); %esperamos un tiempo para evitar accesos de lectura muy frecuentes

% Datos leídos del campo Field1 donde se han almacenado las variables de
% porcentaje. Se leen los datos comprendidos en el rango de tiempo almacenado un poco antes y un poco después
t1 = datetime(2018,09,01); t2 = datetime(2019,12,28);

diaSemana = weekday(datenum(fechaConsulta,'yyyy/mm/dd'));
    
    switch diaSemana
        case 1 %Domingo&
            field = 7;
        case 2 %Lunes%
            field = 1;
        case 3 %Martes%
           field = 2;
        case 4
           field = 3;
        case 5
           field = 4;
        case 6
           field = 5;
        case 7
           field = 6;
    end
datos_Field = thingSpeakRead(ChannelIDParking, 'Fields', field, 'DateRange',[t1,t2],'Readkey',readAPIKeyParking);
datos_Field
datos_Field = datos_Field(~isnan(datos_Field));
datos_Field
p = 2; % orden del modelo
modeloAR = ar(datos_Field,p);

dataField2(1) = p
dataField2(2) = modeloAR.A(1)
for k=3:1:p+2
  dataField2(k) = modeloAR.A(k-1);  
end
% Generar timestamps para los parámetros estimados
tStamps = (datetime('now')-minutes(p+1):minutes(1):datetime('now'))';
% Crear timetable
dataTable = table(tStamps,dataField2');
% Escribir en el campo 5
delay(20);
respuesta = thingSpeakWrite(ChannelIDParking,dataTable,'Fields',8,'Writekey',writeAPIKeyParking);

% Flag en Field 7 para indicar que se han estimado ya los datos
% dataField7 = 1;
% respuesta = thingSpeakWrite(ChannelIDParking,dataField7,'Fields',7,'Writekey',writeAPIKeyParking);

% predicción de los 10 siguientes datos
Horizonte = 10; 
DatosPredichos = forecast(modeloAR,datos_Field,Horizonte);

% función para esperar accesos (de escritura) a datos del canal
function t = delay(segundos)
  % esperar un tiempo mínimo en segundos
  a = datetime('now');
  b = datetime('now');
  t = second(b)-second(a);
  while t < segundos
    b = datetime('now');
    t = second(b)-second(a);
  end
end

