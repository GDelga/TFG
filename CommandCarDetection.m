classdef CommandCarDetection
    methods
        function r = execute(obj, data)
               result = ASFactory.getInstance().createASSmartCities().detection(data);
               if(isnan(result))
                   r = Context(Events.EXECUTE_CAR_DETECTION_OK, result);
               elseif(result == 1)
                   r = Context(Events.EXECUTE_CAR_DETECTION_STOP, 'The video has been stopped');
               else
                   r = Context(Events.EXECUTE_CAR_DETECTION_KO, result);
               end
        end
    end
end