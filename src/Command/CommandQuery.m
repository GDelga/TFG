classdef CommandQuery
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().readByDate(data);
            r = Context(Events.EXECUTE_QUERIES, result);
        end
        
    end
    
end