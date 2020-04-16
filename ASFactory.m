classdef ASFactory
    methods (Static)
        function singleton = getInstance
             persistent local
             if isempty(local)
                local = ASFactoryImp();
             end
             singleton = local;
        end
    end
end