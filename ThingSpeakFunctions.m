classdef ThingSpeakFunctions
   methods
      function r = write(obj, channelID, APIKey, labels, data)
         r = thingSpeakWrite(channelID, data, 'Fields', labels, 'Writekey', APIKey);
      end
      function [data,timestamps,channelInfo] = read(obj, channelID, APIKey, labels)
         [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'Readkey', APIKey);
      end
      function [data,timestamps,channelInfo] = readWithNumber(obj, channelID, APIKey, labels, number)
         [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'NumPoints', number, 'Readkey', APIKey);
      end
      function [data,timestamps,channelInfo] = readWithRange(obj, channelID, APIKey, labels, t1, t2)
         [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'DateRange',[t1,t2], 'Readkey', APIKey);
      end
      function [data,timestamps,channelInfo] = readByDate(obj, channelID, APIKey, labels, initDate, endDate)
        % Convierto las fechas en arrays de strings
        firstDate = split(string(initDate), "-");
        secondDate = split(string(endDate), "-");

        % Realizo la consulta leyendo los datos de los campos deseados
        [data,timestamps,channelInfo] = thingSpeakRead(channelID,'Fields',labels,'DateRange',...
        [datetime(str2num(firstDate(1)),str2num(firstDate(2)),str2num(firstDate(3)),23,59,01),...
        datetime(str2num(secondDate(1)),str2num(secondDate(2)),str2num(secondDate(3)),23,59,01)], ...
        'Readkey', APIKey);
      end
   end
end