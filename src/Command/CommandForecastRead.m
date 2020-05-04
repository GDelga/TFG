classdef CommandForecastRead
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().readWithRange(data);
            if(~ismethod(result, 'isstring'))
                r = Context(Events.EXECUTE_FORECAST_READ_OK, result);
            else
                r = Context(Events.EXECUTE_FORECAST_READ_KO, result);
            end
        end
        
    end
    
end