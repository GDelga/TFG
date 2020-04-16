classdef CommandCarDetection
    methods
        function r = execute(obj, data)
               ASFactory.getInstance().createASSmartCities().carDetection(data);
        end
    end
end