classdef CommandForecastWrite
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().write(data);
            r = Context(Events.EXECUTE_FORECAST_WRITE, data.getData());
        end
        
    end
    
end