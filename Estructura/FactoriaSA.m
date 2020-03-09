classdef (Abstract) FactoriaSA < handle
    properties
        instance
    end
    methods        
        function obj = FactoriaSA()
            obj.instance = NaN;
        end
    end
    methods (Static)
        function r = getInstance(obj)
            if(isnan(obj.instance))
               obj.instance = FactoriaSAImp();
            end
            r = obj.instance;
        end
    end
    methods (Abstract)
        createCarDetection(obj)
        createRetraining(obj)
    end
end