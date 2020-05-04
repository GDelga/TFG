classdef CommandForecastWrite
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().write(data);
            if(~ismethod(result, 'isstring'))
                r = Context(Events.EXECUTE_FORECAST_WRITE_OK, data.getData());
            else
                r = Context(Events.EXECUTE_FORECAST_WRITE_KO, result);
            end
        end
        
    end
    
end