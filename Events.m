classdef Events
   properties (Constant)
      GUI_MAIN = 100
      GUI_LEARNING = 200
      GUI_RETRAINING = 300
      EXECUTE_RETRAINING = 301
      EXECUTE_RETRAINING_OK = 302
      EXECUTE_RETRAINING_KO = 303
      GUI_CAR_DETECTION = 400
      EXECUTE_CAR_DETECTION = 401
      EXECUTE_CAR_DETECTION_OK = 402
      EXECUTE_CAR_DETECTION_KO = 403
      UPDATE_CAR_DETECTION_VIDEO_DATA = 404
      EXECUTE_CAR_DETECTION_STOP = 405
      CAR_DETECTION_VIDEO_LOADED = 406
      GUI_THING_SPEAK = 500
      GUI_QUERIES = 600
      GUI_FORECAST = 700
   end
end