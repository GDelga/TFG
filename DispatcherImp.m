classdef DispatcherImp
    
    properties (Constant)
        GUI_CAR_DETECTION = CarDetection();
        GUI_QUERIES = Queries();
        GUI_FORECAST = Forecast();
    end
    
    properties (Access = private)
        GUI_MAIN
        GUI_LEARNING
        GUI_THING_SPEAK
        GUI_RETRAINING
    end
    
    methods
        
        function obj = DispatcherImp(obj)
            obj.GUI_MAIN = NaN;
            obj.GUI_LEARNING = NaN;
            obj.GUI_THING_SPEAK = NaN;
            obj.GUI_RETRAINING = NaN;
        end
        function generateView(obj, context)
            event = getEvent(context);
            switch event
                case Events.GUI_MAIN
                    if(ismethod(obj.GUI_MAIN,'isnan'))
                        obj.GUI_MAIN = SmartCities();
                    end
                    obj.GUI_MAIN.update(context);
                case Events.GUI_LEARNING
                    if(ismethod(obj.GUI_LEARNING,'isnan'))
                        obj.GUI_LEARNING = Learning();
                    end
                    obj.GUI_LEARNING.update(context);
                case Events.GUI_CAR_DETECTION
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_OK
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_KO
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.UPDATE_CAR_DETECTION_VIDEO_DATA
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_STOP
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.CAR_DETECTION_VIDEO_LOADED
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.GUI_THING_SPEAK
                    obj.GUI_THING_SPEAK.update(context);
                case Events.GUI_QUERIES
                    obj.GUI_QUERIES.update(context);
                case Events.EXECUTE_QUERIES
                     obj.GUI_QUERIES.update(context);
                case Events.GUI_RETRAINING
                    if(ismethod(obj.GUI_RETRAINING,'isnan'))
                        obj.GUI_RETRAINING = Retraining();
                    end
                    obj.GUI_RETRAINING.update(context);
                case Events.EXECUTE_RETRAINING_KO
                    if(ismethod(obj.GUI_RETRAINING,'isnan'))
                        obj.GUI_RETRAINING = Retraining();
                    end
                    obj.GUI_RETRAINING.update(context);
                case Events.EXECUTE_RETRAINING_OK
                    if(ismethod(obj.GUI_RETRAINING,'isnan'))
                        obj.GUI_RETRAINING = Retraining();
                    end
                    obj.GUI_RETRAINING.update(context);
                case Events.GUI_FORECAST
                    obj.GUI_FORECAST.update(context);
                case Events.EXECUTE_FORECAST_READ
                    obj.GUI_FORECAST.update(context);
                case Events.EXECUTE_FORECAST_WRITE
                    obj.GUI_FORECAST.update(context);
            end
        end
    end
end