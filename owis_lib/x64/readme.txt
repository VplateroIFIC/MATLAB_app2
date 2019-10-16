Content of a directory:

- readme.txt this file
- liesmich.txt german version of this file
- PS90.h header file for PS90-DLL
- PS90TOOL_m.txt script file for demo program (e.g., MatLab R2012a)
..\SDK\exe\x86 - demo program (32 bit), 2 batch files
- PS90.dll PS90-function library (version 1.0.9.1, 32 bit)
..\SDK\exe\x64 - demo program (64 bit), 2 batch files
- PS90.dll PS90-function library (version 1.0.9.1, 64 bit)

To use the functions in your application, make the following:
1. Add the file "ps90.h" to the project (or copy to target directory).
2. Add the library "ps90.dll" to the project as file (or copy to target directory).

To use the demo application (64 bit), the following files are required:
- Visual C++ Runtime files
These files can be run as prerequisites during installation on a computer that does not have Visual C++ 2010 Express Edition (or higher) installed.
vcredist_x64.exe - Redistributable Package for Visual C++ (64 bit) 
