%Creación de una interfaz para utilizar la librería del SDK del optoNCDT2300 de microepsilon desde MATLAB

%Primero incluimos la dirección en la que se encuentran los headers que
%queremos incluir en la librería (includePath) en las direcciones que
%MATLAB utiliza para cargar sus programas con setPath.
includePath='C:\Users\max\Desktop\Microepsilon sensors\MATLAB\optoNCDT\MEDAQLib-4.7.0.30086';
addpath(includePath);

%Establecemos los headers de la librería, la dirección en la que queremos
%generar la interfaz, la dirección de los archivos .lib y el nombre de la
%interfaz
headerFiles="MEDAQLib-4.7.0.30086\MEDAQLib.h";
outputFolder=pwd;
libraries=fullfile(includePath,"Release-x64","MEDAQLib.lib");
packageName="MEDAQLib";

%Llamamos a clibgen.generateLibraryDefinition
clibgen.generateLibraryDefinition(headerFiles,'IncludePath',includePath,'Libraries',libraries,...
    'OutputFolder',outputFolder,'PackageName',packageName,'Verbose',true)