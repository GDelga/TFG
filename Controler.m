classdef Controler
    methods (Static)
        function singleton = getInstance
             persistent local
             if isempty(local)
                local = ControlerImp();
             end
             singleton = local;
        end
    end
end