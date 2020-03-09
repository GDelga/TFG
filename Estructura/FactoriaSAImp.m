classdef FactoriaSAImp < FactoriaSA
    properties (SetAccess = private)
        carDetection
    end
    methods        
        function obj = FactoriaSAImp()
            %carDetection = CarDetectionFuncionality();
        end
        
        function r = getInstance(obj)
            if(isnan(obj.instance))
               obj.instance = FactoriaSAImp();
            end
            r = obj.instance;
        end
        
        function createCarDetection(obj)
            
        end
         
        function createRetraining(obj)
               
        end
    end
end