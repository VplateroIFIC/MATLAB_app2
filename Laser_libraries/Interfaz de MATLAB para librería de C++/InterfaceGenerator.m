%Creación de una interfaz para utilizar la librería del SDK del scanCONTROL2950-50 de microepsilon desde MATLAB

%Primero incluimos la dirección en la que se encuentran los headers que
%queremos incluir en la librería (includePath) en las direcciones que
%MATLAB utiliza para cargar sus programas con setPath.
includePath='C:\Users\max\Desktop\Microepsilon sensors\MATLAB\scanCONTROL\C++ SDK (+python bindings)';
setPath(includePath);

%Establecemos los headers de la librería, la dirección en la que queremos
%generar la interfaz, la dirección de los archivos .lib y el nombre de la
%interfaz
headerFiles="C++ SDK (+python bindings)\S_InterfaceLLT_2.h";
outputFolder=pwd;
libraries=fullfile(includePath,"lib","x64","LLT.lib");
packageName="LLT";

%Llamamos a clibgen.generateLibraryDefinition
clibgen.generateLibraryDefinition(headerFiles,'IncludePath',includePath,'Libraries',libraries,...
    'OutputFolder',outputFolder,'PackageName',packageName,'Verbose',true)