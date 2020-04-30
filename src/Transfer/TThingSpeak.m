classdef TThingSpeak
    
    properties (Access = private)
        channelID
        APIKey
        labels
        data
        range1
        range2
        number
    end
    
    methods
        
        function obj = TThingSpeak(channelID, APIKey, labels, data,...
                range1, range2, number)
            obj.channelID = channelID;
            obj.APIKey = APIKey;
            obj.labels = labels;
            obj.data = data;
            obj.range1 = range1;
            obj.range2 = range2;
            obj.number = number;
        end
        
        function r = getChannelID(obj)
            r = obj.channelID;
        end
        
        function r = getAPIKey(obj)
            r = obj.APIKey;
        end
        
        function r = getLabels(obj)
            r = obj.labels;
        end
        
        function r = getData(obj)
            r = obj.data;
        end
        
        function r = getRange1(obj)
            r = obj.range1;
        end
        
        function r = getRange2(obj)
            r = obj.range2;
        end
        
        function r = getNumber(obj)
            r = obj.number;
        end
        
    end
end