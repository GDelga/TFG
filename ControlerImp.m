classdef ControlerImp
    methods
        function execute(obj, context)
            command = CommandFactory.getInstance().generateCommand(context.getEvent());
            result = NaN;
            if (~isnan(command))
                result = command.execute(contexto.getDato());
                Dispatcher.getInstance().generarVista(contextoResult);
            else Dispatcher.getInstance().generateView(context);
            end
        end
    end
end