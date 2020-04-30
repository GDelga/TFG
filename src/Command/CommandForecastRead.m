classdef CommandForecastRead
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().readWithRange(data);
            r = Context(Events.EXECUTE_FORECAST_READ, result);
        end
        
    end
    
end