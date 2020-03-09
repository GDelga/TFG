T = readtable('FicherosCSV/08-2018.csv');
lunes_fechas =[];
lunes_inten = [];

martes_fechas =[];
martes_inten =[];

miercoles_fechas =[];
miercoles_inten =[];

jueves_fechas =[];
jueves_inten =[];

viernes_fechas =[];
viernes_inten =[];

sabado_fechas =[];
sabado_inten =[];

domingo_fechas =[];
domingo_inten = [];

for dia = [1:28]
fechaAct = dia + "/08/2018 16:00";
suma = 0;
filasID = find(T.id == 1001 & T.fecha >= + dia + "/08/2018 16:00" & T.fecha <= + dia +"/08/2018 18:00" & T.tipo_elem == "M30");
    for fila = filasID
        suma = sum(T.intensidad(fila)); 
    end
    diaSemana = weekday(datenum(fechaAct,'dd/mm/yyyy hh:MM'));
    
    switch diaSemana
        case 1 %Domingo&
            domingo_fechas = [domingo_fechas;fechaAct];
            domingo_inten = [domingo_inten;suma];
        case 2 %Lunes%
            lunes_fechas = [lunes_fechas;fechaAct];
            lunes_inten = [lunes_inten;suma];
        case 3 %Martes%
           martes_fechas = [martes_fechas;fechaAct];
           martes_inten = [martes_inten;suma];
        case 4
           miercoles_fechas = [miercoles_fechas;fechaAct];
           miercoles_inten = [miercoles_inten;suma];
        case 5
           jueves_fechas = [jueves_fechas;fechaAct];
           jueves_inten = [jueves_inten;suma];
        case 6
           viernes_fechas = [viernes_fechas;fechaAct];
           viernes_inten = [viernes_inten;suma];
        case 7
           sabado_fechas = [sabado_fechas;fechaAct];
           sabado_inten = [sabado_inten;suma];
    end
            

end
datetime = lunes_fechas;
field1 = lunes_inten;
TF = table(datetime,field1);
 writetable(TF,'FicherosCSV/2018/Lunes.csv','Delimiter',',');

datetime = martes_fechas;
field2 = martes_inten;
TF = table(datetime,field2);
 writetable(TF,'FicherosCSV/2018/Martes.csv','Delimiter',',');
 
 datetime = miercoles_fechas;
field3 = miercoles_inten;
TF = table(datetime,field3);
 writetable(TF,'FicherosCSV/2018/Miercoles.csv','Delimiter',',');
 
 datetime = jueves_fechas;
field4 = jueves_inten;
TF = table(datetime,field4);
 writetable(TF,'FicherosCSV/2018/Jueves.csv','Delimiter',',');
 
 datetime = viernes_fechas;
field5 = viernes_inten;
TF = table(datetime,field5);
 writetable(TF,'FicherosCSV/2018/Viernes.csv','Delimiter',',');
 
 datetime = sabado_fechas;
field6 = sabado_inten;
TF = table(datetime,field6);
 writetable(TF,'FicherosCSV/2018/Sabado.csv','Delimiter',',');
 
 datetime = domingo_fechas;
field7= domingo_inten;
TF = table(datetime,field7);
 writetable(TF,'FicherosCSV/2018/Domingo.csv','Delimiter',',');
 
 



