function bol = setPath(newPath)
%This function adds the newPath to the system enviromental variable PATH, which is
%the list of paths 

try
    path=getenv('PATH');                                
    setenv('PATH',[newPath ';' path]);                 
    bol=true;
catch ME
    warning("Path couldn't be included");
    warning(ME.message);
    bol=false;
end