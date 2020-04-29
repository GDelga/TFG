classdef TCarDetection
    
    properties (Access = private)
        directory
        videoName
        isStop
    end
    
    methods
        
        function obj = TCarDetection(directory, videoName, isStop)
            obj.directory = directory;
            obj.videoName = videoName;
            obj.isStop = isStop;
        end
        
        function r = getIsStop(obj)
            r = obj.isStop;
        end
        
        function r = getVideoName(obj)
            r = obj.videoName;
        end
        
        function r = getDirectory(obj)
            r = obj.directory;
        end
        
    end
    
end