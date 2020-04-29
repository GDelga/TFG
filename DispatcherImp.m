classdef DispatcherImp
    properties (Access = private)
      GUI_MAIN
      GUI_LEARNING
      GUI_CAR_DETECTION
      GUI_THING_SPEAK
      GUI_QUERIES
      GUI_RETRAINING
      GUI_FORECAST
    end
    methods
        
        function obj = DispatcherImp(obj)
            obj.GUI_MAIN = NaN;
            obj.GUI_LEARNING = NaN;
            obj.GUI_CAR_DETECTION = NaN;
            obj.GUI_THING_SPEAK = NaN;
            obj.GUI_QUERIES = NaN;
            obj.GUI_RETRAINING = NaN;
            obj.GUI_FORECAST = NaN;
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
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_OK
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_KO
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.UPDATE_CAR_DETECTION_VIDEO_DATA
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_STOP
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.CAR_DETECTION_VIDEO_LOADED
                    if(ismethod(obj.GUI_CAR_DETECTION,'isnan'))
                        obj.GUI_CAR_DETECTION = CarDetection();
                    end
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.GUI_THING_SPEAK
                    if(ismethod(obj.GUI_THING_SPEAK,'isnan'))
                        obj.GUI_THING_SPEAK = ThingSpeak();
                    end
                    obj.GUI_THING_SPEAK.update(context);
                case Events.GUI_QUERIES
                    if(ismethod(obj.GUI_QUERIES,'isnan'))
                        obj.GUI_QUERIES = Queries();
                    end
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
                    if(ismethod(obj.GUI_FORECAST,'isnan'))
                        obj.GUI_FORECAST = Forecast();
                    end
                    obj.GUI_FORECAST.update(context);
            end            
        end
    end
end