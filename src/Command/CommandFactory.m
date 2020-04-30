classdef CommandFactory
    methods (Static)
        function singleton = getInstance
            import src.Command.*
            persistent local
            if isempty(local)
                local = CommandFactoryImp();
            end
            singleton = local;
        end
    end
end