classdef Context
   properties (Access = private)
      event
      data
   end
   methods        
        function obj = Context(event, data)
            obj.event = event;
            obj.data = data;
        end
        function r = getData(obj)
            r = obj.data;
        end
        function r = getEvent(obj)
            r = obj.event;
        end
   end
end