classdef CommandRetraining
    methods
        function r = execute(obj, data)
               ASFactory.getInstance().createASSmartCities().retraining(data);
        end
    end
end