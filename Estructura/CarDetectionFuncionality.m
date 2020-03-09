classdef (Abstract) CarDetectionFuncionality < handle
    properties (SetAccess = private)
        instance
    end
    methods        
        function obj = CarDetectionFuncionality()
            obj.instance = NaN;
        end
        
        function r = getInstance(obj)
            if(isnan(obj.instance))
               obj.instance = CarDetectionFuncionalityImp();
            end
            r = obj.instance;
        end
    end
    methods (Abstract)
        runDetection(obj)
    end
end