function bol = setPath(newPath)

try
    path=getenv('PATH');                                %La variable ambiental 'PATH' contiene las direcciones en las que MATLAB busca los archivos que utiliza 
    setenv('PATH',[newPath ';' path]);                  %Incluimos el newPath al inicio de todas las direcciones
    bol=true;
catch ME
    warning("Path couldn't be included");
    warning(ME.message);
    bol=false;
end