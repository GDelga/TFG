classdef ControlerImp
    
    methods
        
        function execute(obj, context)
            import src.Command.*
            import src.Context.*
            import src.Dispatcher.*
            command = CommandFactory.getInstance().generateCommand(context.getEvent());
            if (~ismethod(command,'isnan'))
                result = command.execute(context.getData());
                Dispatcher.getInstance().generateView(result);
            else Dispatcher.getInstance().generateView(context);
            end
        end
        
    end
    
end