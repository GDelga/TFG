classdef CommandQuery
    
    methods
        
        function r = execute(obj, data)
            result = ASFactory.getInstance().createASThingSpeak().readByDate(data);
            r = Context(Events.EXECUTE_QUERIES, result);
        end
        
    end
    
end