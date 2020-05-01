classdef CommandCarDetection
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASSmartCities().detection(data);
            if(~isnumeric(result) && ismethod(result,'isnan'))
                r = Context(Events.EXECUTE_CAR_DETECTION_OK, result);
            elseif(isnumeric(result) && result == 1)
                r = Context(Events.EXECUTE_CAR_DETECTION_STOP, 'The video has been stopped');
            else
                r = Context(Events.EXECUTE_CAR_DETECTION_KO, result);
            end
        end
        
    end
    
end