classdef CommandFactory
    methods (Static)
        function singleton = getInstance
            persistent local
            if isempty(local)
                local = CommandFactoryImp();
            end
            singleton = local;
        end
    end
end