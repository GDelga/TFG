classdef ASThingSpeak
    
    methods
        
        function r = write(obj, tThingSpeak)
            import src.Transfer.*
            data = tThingSpeak.getData();
            channelID = tThingSpeak.getChannelID();
            labels = tThingSpeak.getLabels();
            APIKey = tThingSpeak.getAPIKey();
            try
                thingSpeakWrite(channelID, data, 'Fields', labels, 'Writekey', APIKey);
                r = NaN;
            catch
                r = "The operation could not be performed. Try again.";
            end
        end
        
        function r = read(obj, tThingSpeak)
            import src.Transfer.*
            channelID = tThingSpeak.getChannelID();
            labels = tThingSpeak.getLabels();
            APIKey = tThingSpeak.getAPIKey();
            try
                [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'Readkey', APIKey);
                r = TThingSpeakResult(labels, data, timestamps, channelInfo);
            catch
                r = "The operation could not be performed. Try again.";
            end
        end
        
        function r = readWithNumber(obj, tThingSpeak)
            import src.Transfer.*
            number = tThingSpeak.getNumber();
            channelID = tThingSpeak.getChannelID();
            labels = tThingSpeak.getLabels();
            APIKey = tThingSpeak.getAPIKey();
            try
                [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'NumPoints', number, 'Readkey', APIKey);
                r = TThingSpeakResult(labels, data, timestamps, channelInfo);
            catch
                r = "The operation could not be performed. Try again.";
            end
        end
        
        function r = readWithRange(obj, tThingSpeak)
            import src.Transfer.*
            t1 = tThingSpeak.getRange1();
            t2 = tThingSpeak.getRange2();
            channelID = tThingSpeak.getChannelID();
            labels = tThingSpeak.getLabels();
            APIKey = tThingSpeak.getAPIKey();
            try
                [data,timestamps,channelInfo] = thingSpeakRead(channelID, 'Fields', labels, 'DateRange',[t1,t2], 'Readkey', APIKey);
                r = TThingSpeakResult(labels, data, timestamps, channelInfo);
            catch
                r = "The operation could not be performed. Try again.";
            end
        end
        
        function r = readByDate(obj, tThingSpeak)
            import src.Transfer.*
            initDate = tThingSpeak.getRange1();
            endDate = tThingSpeak.getRange2();
            channelID = tThingSpeak.getChannelID();
            labels = tThingSpeak.getLabels();
            APIKey = tThingSpeak.getAPIKey();
            % Convierto las fechas en arrays de strings
            firstDate = split(string(initDate), "-");
            secondDate = split(string(endDate), "-");
            
            % Realizo la consulta leyendo los datos de los campos deseados
            try
                [data,timestamps,channelInfo] = thingSpeakRead(channelID,'Fields',labels,'DateRange',...
                    [datetime(str2num(firstDate(1)),str2num(firstDate(2)),str2num(firstDate(3)),23,59,01),...
                    datetime(str2num(secondDate(1)),str2num(secondDate(2)),str2num(secondDate(3)),23,59,01)], ...
                    'Readkey', APIKey);
                r = TThingSpeakResult(labels, data, timestamps, channelInfo);
            catch
                r = "The operation could not be performed. Try again.";
            end
        end
        
    end
    
end