classdef ThingSpeakFunctions
   methods
      function r = write(obj, channelID, APIKey, labels, data)
         r = thingSpeakWrite(channelID, data, 'Fields', labels, 'Writekey', APIKey);
      end
      function [data,timestamps,channelInfo] = read(obj, channelID, APIKey, labels)
         [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'Readkey', APIKey);
      end
   end
end