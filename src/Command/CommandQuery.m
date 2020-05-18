classdef CommandQuery
    
    methods
        
        function r = execute(obj, data)
            import src.AS.*
            import src.Context.*
            result = ASFactory.getInstance().createASThingSpeak().readByDate(data);
            if(~ismethod(result, 'isstring'))
                r = Context(Events.EXECUTE_QUERIES_OK, result);
            else
                r = Context(Events.EXECUTE_QUERIES_KO, result);
            end
        end
        
    end
    
end