classdef ASFactoryImp
    methods
        function r = createASSmartCities(obj)
             r = ASSmartCities();
        end
        
        function r = createASThingSpeak(obj)
             r = ASThingSpeak();
        end
    end
end