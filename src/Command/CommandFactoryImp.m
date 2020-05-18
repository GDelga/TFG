classdef CommandFactoryImp
    methods
        function r = generateCommand(obj, event)
            import src.Context.*
            switch event
                case Events.EXECUTE_RETRAINING
                    r = CommandRetraining();
                case Events.EXECUTE_CAR_DETECTION
                    r = CommandCarDetection();
                case Events.EXECUTE_FORECAST_WRITE
                    r = CommandForecastWrite();
                case Events.EXECUTE_FORECAST_READ
                    r = CommandForecastRead();
                case Events.EXECUTE_QUERIES
                    r = CommandQuery();
                otherwise
                    r = NaN;
            end     
        end
    end
end