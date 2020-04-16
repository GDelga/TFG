classdef TConfigData
   properties (Access = private)
       WeightLearnRateFactor
       BiasLearnRateFactor
       SolverMethod
       MiniBatchSize
       MaxEpochs
       InitialLearnRate
       ValidationFrequency
       ValidationPatience
   end
   methods        
        function obj = TConfigData(WeightLearnRateFactor, BiasLearnRateFactor, SolverMethod,...
                MiniBatchSize, MaxEpochs, InitialLearnRate, ValidationFrequency,ValidationPatience)
           obj.WeightLearnRateFactor = WeightLearnRateFactor;
           obj.BiasLearnRateFactor = BiasLearnRateFactor;
           obj.SolverMethod = SolverMethod;
           obj.MiniBatchSize = MiniBatchSize;
           obj.MaxEpochs = MaxEpochs;
           obj.InitialLearnRate = InitialLearnRate;
           obj.ValidationFrequency = ValidationFrequency;
           obj.ValidationPatience = ValidationPatience;
        end
        function r = getWeightLearnRateFactor(obj)
            r = obj.WeightLearnRateFactor;
        end
        function r = getBiasLearnRateFactor(obj)
            r = obj.BiasLearnRateFactor;
        end
        function r = getSolverMethod(obj)
            r = obj.SolverMethod;
        end
        function r = getMiniBatchSize(obj)
            r = obj.MiniBatchSize;
        end
        function r = getMaxEpochs(obj)
            r = obj.MaxEpochs;
        end
        function r = getInitialLearnRate(obj)
            r = obj.InitialLearnRate;
        end
        function r = getValidationFrequency(obj)
            r = obj.ValidationFrequency;
        end
        function r = getValidationPatience(obj)
            r = obj.ValidationPatience;
        end
   end
end