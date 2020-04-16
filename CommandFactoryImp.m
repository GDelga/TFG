classdef CommandFactoryImp
    methods
        function r = generateCommand(obj, event)
            switch event
                case Events.EXECUTE_RETRAINING
                    r = CommandRetraining();
                case Events.EXECUTE_CAR_DETECTION
                    r = CommandCarDetection();
                otherwise
                    r = NaN;
            end     
        end
    end
end