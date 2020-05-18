classdef TVideoData
   properties (Access = private)
       videoImage
       detectImage
       detectionData
       tCarDetectionData
   end
   methods        
        function obj = TVideoData(videoImage, detectImage, detectionData, tCarDetectionData)
           obj.videoImage = videoImage;
           obj.detectImage = detectImage;
           obj.detectionData = detectionData;
           obj.tCarDetectionData = tCarDetectionData;
        end
        function r = getVideoImage(obj)
            r = obj.videoImage;
        end
        function r = getDetectImage(obj)
            r = obj.detectImage;
        end
        function r = getDetectionData(obj)
            r = obj.detectionData;
        end
        function r = getTCarDetectionData(obj)
            r = obj.tCarDetectionData;
        end
   end
end