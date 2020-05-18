classdef Dispatcher
    methods (Static)
        function singleton = getInstance
            import src.Dispatcher.*
            persistent local
            if isempty(local)
                local = DispatcherImp();
            end
            singleton = local;
        end
    end
end