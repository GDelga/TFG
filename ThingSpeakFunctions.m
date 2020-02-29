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
   end
end