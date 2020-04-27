classdef DispatcherImp
    properties (Constant)
      GUI_MAIN = SmartCities();
      GUI_LEARNING = Learning();
      GUI_CAR_DETECTION = CarDetection();
      GUI_THING_SPEAK = ThingSpeak();
      GUI_QUERIES = Queries();
      GUI_RETRAINING = Retraining();
      GUI_FORECAST = Forecast();
   end
    methods
        function generateView(obj, context)
            event = getEvent(context);
            switch event
                case Events.GUI_MAIN
                    obj.GUI_MAIN.update(context);
                case Events.GUI_LEARNING
                    obj.GUI_LEARNING.update(context);
                case Events.GUI_CAR_DETECTION
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_OK
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.EXECUTE_CAR_DETECTION_KO
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.UPDATE_CAR_DETECTION_VIDEO_DATA
                    obj.GUI_CAR_DETECTION.update(context);
                case Events.GUI_THING_SPEAK
                    obj.GUI_THING_SPEAK.update(context);
                case Events.GUI_QUERIES
                    obj.GUI_QUERIES.update(context);
                case Events.GUI_RETRAINING
                    obj.GUI_RETRAINING.update(context);
                case Events.EXECUTE_RETRAINING_KO
                    obj.GUI_RETRAINING.update(context);
                case Events.EXECUTE_RETRAINING_OK
                    obj.GUI_RETRAINING.update(context);
                case Events.GUI_FORECAST
                    obj.GUI_FORECAST.update(context);
            end            
        end
    end
end