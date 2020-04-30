classdef TCarDetectionData
   properties (Access = private)
       XSupIzda
       XSupDcha
       XInfIzda
       XInfDcha
       YSupIzda
       YSupDcha
       YInfIzda
       YInfDcha
       category
       color
   end
   methods        
        function obj = TCarDetectionData(XSupIzda, XSupDcha, XInfIzda, XInfDcha,...
                YSupIzda, YSupDcha, YInfIzda, YInfDcha, category, color)
           obj.XSupIzda = XSupIzda;
           obj.XSupDcha = XSupDcha;
           obj.XInfIzda = XInfIzda;
           obj.XInfDcha = XInfDcha;
           obj.YSupIzda = YSupIzda;
           obj.YSupDcha = YSupDcha;
           obj.YInfIzda = YInfIzda;
           obj.YInfDcha = YInfDcha;
           obj.category = category;
           obj.color = color;
        end
        function r = getXSupIzda(obj)
            r = obj.XSupIzda;
        end
        function r = getXSupDcha(obj)
            r = obj.XSupDcha;
        end
        function r = getXInfIzda(obj)
            r = obj.XInfIzda;
        end
        function r = getXInfDcha(obj)
            r = obj.XInfDcha;
        end
        function r = getYSupIzda(obj)
            r = obj.YSupIzda;
        end
        function r = getYSupDcha(obj)
            r = obj.YSupDcha;
        end
        function r = getYInfIzda(obj)
            r = obj.YInfIzda;
        end
        function r = getYInfDcha(obj)
            r = obj.YInfDcha;
        end
        function r = getCategory(obj)
            r = obj.category;
        end
        function r = getColor(obj)
            r = obj.color;
        end
   end
end