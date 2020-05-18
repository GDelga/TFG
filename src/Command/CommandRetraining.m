classdef CommandRetraining
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASSmartCities().retraining(data);
            if(ismethod(result,'isnan'))
                r = Context(Events.EXECUTE_RETRAINING_OK, result);
            else
                r = Context(Events.EXECUTE_RETRAINING_KO, result);
            end
        end
        
    end
    
end