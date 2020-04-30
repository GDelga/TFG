classdef TThingSpeakResult
    
    properties (Access = private)
        labels
        data
        timestamps
        channelInfo
    end
    
    methods
        
        function obj = TThingSpeakResult(labels, data, timestamps, channelInfo)
            obj.labels = labels;
            obj.data = data;
            obj.timestamps = timestamps;
            obj.channelInfo = channelInfo;
        end
        
        function r = getLabels(obj)
            r = obj.labels;
        end
        
        function r = getData(obj)
            r = obj.data;
        end
        
        function r = getTimestamps(obj)
            r = obj.timestamps;
        end
        
        function r = getChannelInfo(obj)
            r = obj.channelInfo;
        end
        
    end
end