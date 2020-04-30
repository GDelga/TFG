import src.GUI.*
import src.Controler.*
import src.Context.*
close all force;
delete(ThingSpeak); delete(SmartCities); delete(Retraining);
delete(Learning); delete(CarDetection); delete(Queries); delete(Forecast);
clc; clear; clear all; clear classes; clear java;
Controler.getInstance().execute(Context(Events.GUI_MAIN, NaN));