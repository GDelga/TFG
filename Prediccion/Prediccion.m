data = thingSpeakRead(1005862, 'Fields', [1,2], 'NumPoints', 1, 'Readkey', 'Z0G6S3M8BP1GZQXJ', 'OutputFormat', 'table');
horizon = data.Horizon;
day = char(data.Day);
t1 = datetime(2018,09,01,15,00,00);
switch day
    case 'Monday'
        field = 1;
        t2 = datetime(2019,12,23,15,00,00);
    case 'Tuesday'
       field = 2;
       t2 = datetime(2019,12,24,15,00,00);
    case 'Wednesday'
       field = 3;
       t2 = datetime(2019,12,25,15,00,00);
    case 'Thursday'
       field = 4;
       t2 = datetime(2019,12,26,15,00,00);
    case 'Friday'
       field = 5;
       t2 = datetime(2019,12,27,15,00,00);
    case 'Saturday'
       field = 6;
       t2 = datetime(2019,12,28,15,00,00);
    case 'Sunday'
       field = 7;
       t2 = datetime(2019,12,29,15,00,00);
end
% Generate timestamps
tStamps = (t2 + days(7:7:(horizon*7)))';
t2 = t2 + days(7);
datos_Field = thingSpeakRead(990311, 'Fields', field, 'DateRange',[t1,t2],'Readkey', 'OC3B1ZHFICPHHAHE');
datos_Field = datos_Field(~isnan(datos_Field));

p = 2;
modeloAR = ar(datos_Field,p);
predictionData = forecast(modeloAR, datos_Field, horizon);

respuesta = thingSpeakWrite(1005368, predictionData, 'TimeStamp', tStamps, 'Fields', field, 'Writekey', 'N22NRN4T7KQ8K6U6')