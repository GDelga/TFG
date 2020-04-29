classdef CommandForecastRead
    
    methods
        
        function r = execute(obj, data)
            result = ASFactory.getInstance().createASThingSpeak().readWithRange(data);
            r = Context(Events.EXECUTE_FORECAST_READ, result);
        end
        
    end
    
end