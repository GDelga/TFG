%Sunday Code
field = 7;
t1 = datetime(2018,09,01); t2 = datetime(2019,12,28);
datos_Field = thingSpeakRead(990311, 'Fields', field, 'DateRange',[t1,t2],'Readkey', 'OC3B1ZHFICPHHAHE');
datos_Field = datos_Field(~isnan(datos_Field));
horizon = thingSpeakRead(1004233, 'Fields', field, 'DateRange',[t1,t2],'Readkey',readAPIKeyParking);

p = 2;
modeloAR = ar(datos_Field,p);
predictionData = forecast(modeloAR, datos_Field, horizon);
% Generate timestamps
tStamps = (predictionData + days(7:(horizon*7)))';
% Create timetable
dataTable = table(tStamps, predictionData');
respuesta = thingSpeakWrite(1005368, dataTable, 'Fields', field, 'Writekey', 'N22NRN4T7KQ8K6U6')

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

