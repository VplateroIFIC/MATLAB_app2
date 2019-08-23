#include "magrathea.h"
#include <QMainWindow>
#include <QMessageBox>
#include <QFileDialog>
#include <QFile>
#include <iostream>
#include <QPushButton>
#include <windows.h>
#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <QByteArray>
#include <fstream>
#include <string>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <unistd.h>
#include <conio.h>
#include <QTimer>
#include <QtDebug>
#include <stdio.h>
#include <stdlib.h>
#include <QTimer>
#include <QElapsedTimer>



//function to write in appropriate way exadecimal number to ultimusV
QByteArray int_tohexQByteArray_UltimusV(int input){
    auto && oss = std::ostringstream();
    oss << std::hex << std::setw(2) << std::setfill('0')
        << input;
    auto && buf = oss.str();
    //add the stx
    QByteArray writeData = QByteArray(buf.c_str());
    for(int i=0;i<writeData.size();i++){
        switch (writeData[i]) {
        case 'a' : writeData[i] = 'A'; break;
        case 'b' : writeData[i] = 'B'; break;
        case 'c' : writeData[i] = 'C'; break;
        case 'd' : writeData[i] = 'D'; break;
        case 'e' : writeData[i] = 'E'; break;
        case 'f' : writeData[i] = 'F'; break;
        default: break;
        }
    }
    return writeData;
}


bool Magrathea::dispenser_init()

{

if(!RS232V("E6  00"))
 {   qDebug() << "Error in E6   command, pressure units";
    return false;
 }
 ui->dispenserPressureUnitsLabel->setText("Dispensing units: psi");

// Temporized Mode

if(!RS232V("TT  "))
 {   qDebug() << "Error in TT   command, temporized mode";
    return false;

}
ui->dispenserModeLabel->setText("Dispensing Mode: Temporized");

if(!RS232V("PS  0500"))
 {   qDebug() << "Error in PS   command, pressure";
    return false;
}

ui->dispenserPressureLabel->setText("Dispensing Pressure: 50");

if(!RS232V("DS  T10000"))
 {   qDebug() << "Error in DS   command, time";
    return false;
}
ui->dispenserTimeLabel->setText("Dispensing time: 1");

if(!RS232V("VS  0050"))
 {   qDebug() << "Error in VS   command, vacuum";
    return false;
}
ui->dispenserVacuumLabel->setText("Dispensing Vacuum: 0.5");


// Continuos Mode

//if(!RS232V("MT  "))
//    qDebug() << "Error in TT   command, Continuos mode"
//    return false;
//
//if(!RS232V("PS  0500"))
//    qDebug() << "Error in PS   command, pressure"
//    return false;

return true;
}

bool Magrathea::dispenser_mode()
{

if(!RS232V("TM  "))
   { qDebug() << "Error in TT   command, temporized mode";
    return false;
}

QByteArray currentMode;
currentMode.append(ui->dispenserModeLabel->text());
if (currentMode=="Dispensing Mode: Temporized")
    ui->dispenserModeLabel->setText("Dispensing Mode: Continuous");
else
    ui->dispenserModeLabel->setText("Dispensing Mode: Temporized");
return true;
}

bool Magrathea::dispenser_pressure()
{
QByteArray newPressure;
newPressure.append(ui->dispenserPressure->text());
newPressure.insert(0,QByteArray ("PS  "));

if(!RS232V(newPressure))
 {   qDebug() << "Error in PS   command, pressure";
    return false;
}
    newPressure.remove(0,4);
    newPressure.insert(3,".");
    newPressure.insert(0,QByteArray ("Dispensing Pressure: "));
ui->dispenserPressureLabel->setText(newPressure);
return true;
}

bool Magrathea::dispenser_pressureUnits()
{
QByteArray newUnits;
newUnits.append(ui->dispenserPressureUnits->text());
newUnits.insert(0,QByteArray ("E6  "));

if(!RS232V(newUnits))
 {   qDebug() << "Error in E6   command, pressure units";
    return false;
}
ui->dispenserPressureUnitsLabel->setText("Dispensing units: psi");
newUnits.remove(0,4);

        if (newUnits=="00"){ newUnits.clear(); newUnits.append("psi");}
        if (newUnits=="01"){ newUnits.clear(); newUnits.append("bar");}
        if (newUnits=="02"){ newUnits.clear(); newUnits.append("kpa");}


newUnits.insert(0,QByteArray ("Dispensing Units: "));
ui->dispenserPressureUnitsLabel->setText(newUnits);

return true;
}

bool Magrathea::dispenser_time()
{

QByteArray newTime;
newTime.append(ui->dispenserTime->text());
newTime.insert(0,QByteArray ("DS  "));

if(!RS232V(newTime))
  {  qDebug() << "Error in DS   command, Time";
    return false;
}
    newTime.remove(0,4);
    newTime.insert(2,".");
    newTime.insert(0,QByteArray ("Dispensing Time: "));
ui->dispenserTimeLabel->setText(newTime);
return true;

}

bool Magrathea::dispenser_vacuum()
{
QByteArray newVacuum;
newVacuum.append(ui->dispenserVacuum->text());
newVacuum.insert(0,QByteArray ("VS  "));

if(!RS232V(newVacuum))
 {   qDebug() << "Error in VS   command, Vacuum";
    return false;
}
    newVacuum.remove(0,4);
    newVacuum.insert(2,".");
    newVacuum.insert(0,QByteArray ("Dispensing Vacuum: "));
ui->dispenserVacuumLabel->setText(newVacuum);

return true;
}





bool Magrathea::RS232V(QByteArray command)
{

//Initialization of serial port

bool debug = false;

    QByteArray readData;
    QByteArray writeData;
    QSerialPort serialPort;
    const QString serialPortName = "COM4"; //to modify according to the serial port used
    serialPort.setPortName(serialPortName);
    serialPort.setBaudRate(QSerialPort::Baud115200); // set BaudRate to 115200
    serialPort.setParity(QSerialPort::NoParity); //set Parity Bit to None
    serialPort.setStopBits(QSerialPort::OneStop); //set
    serialPort.setDataBits(QSerialPort::Data8); //DataBits to 8
    serialPort.setFlowControl(QSerialPort::NoFlowControl);
    serialPort.close();
    if (!serialPort.open(QIODevice::ReadWrite)) {
        std::cout<<"FAIL!!!!!"<<std::endl;
        qWarning("Failed to open port %s, error: %s",serialPortName.toLocal8Bit().constData(),serialPort.errorString().toLocal8Bit().constData());
        return false;
    }else {
        if (debug)
            std::cout<<"Port opened successfully"<<std::endl;
    }




// building command line



//command=ui->dispenserCommand->text().toLatin1();

QByteArray full_order;
full_order[0] = 2;
//qDebug() << command;

int size_command_line;
size_command_line=command.size();
QByteArray order;
QByteArray cs_temp;
QByteArray cs;
order=int_tohexQByteArray_UltimusV(size_command_line);

for(int i=0;i<command.size();i++)
order.append(command[i]);

int checksum = 0;
for(int i=0;i<order.size();i++)// evauating checksum quantity
checksum -= order[i];

    cs_temp = int_tohexQByteArray_UltimusV(checksum & 0x000000ff);
    cs.clear();
    if(cs_temp.size() > 2){
        if (debug)
            qDebug() <<"here : "<<cs_temp.size()<<"  :  " << cs_temp ;
        cs = cs_temp.remove(0,(cs_temp.size()-2));
        if (debug)
            qDebug() <<"CS  :  "<<cs ;
    } else {
        cs = cs_temp;
        if (debug)
            qDebug() <<"CS  :  "<<cs ;
    }

 if(debug) qDebug() << order <<checksum << cs ;

full_order.append(order);
full_order.append(cs);
full_order.append(QByteArrayLiteral("\x03"));

  writeData = QByteArrayLiteral("\x05"); //sending enquiry command
   long long int output = 0;
   output = serialPort.write(writeData);
   if (debug)
       qDebug() <<"Log >> bytes written   : " <<output<< " : operation : "<<writeData;
   if(output == -1){
       qDebug() <<"Error write operation : "<<writeData << " => " << serialPort.errorString();
       return false;
   }


// sending ENQ

QByteArray enq;
enq[0]=0x05;

 output = serialPort.write(enq);
    if (debug)
        qDebug() <<"Log >> bytes written   : " <<enq<< " : operation : "<<enq;
    if(output == -1){
        qDebug() <<"Error write operation : "<<enq << " => " << serialPort.errorString();
        return false;
    }

// reading ACK

int endRead=0;
int control;
  while(endRead==0)
{
   readData.clear();
   control = 0;
   while(serialPort.isOpen()){ // READING BYTES FROM SERIAL PORT
       control += 1;
       //https://stackoverflow.com/questions/42576537/qt-serial-port-reading
       if(!serialPort.waitForReadyRead(100)) //block until new data arrives, dangerous, need a fix
            qDebug() << "Read error: " << serialPort.errorString() ;
       else{
           if (debug)
                qDebug() << "New data available: " << serialPort.bytesAvailable() ;
           readData = serialPort.readAll();

           if (debug)
                qDebug() << readData;
           break;
       }
       if (control > 10){
            qDebug() << "Time out read error";
           return false;
       }
}
if (readData.endsWith("\x06"))
        endRead=1;
}

// sending command


    output = serialPort.write(full_order);
    if (debug)
        qDebug() <<"Log >> bytes written   : " <<output<< " : operation : "<<full_order;
    if(output == -1){
        qDebug() <<"Error write operation : "<<full_order << " => " << serialPort.errorString();
        return false;
    }



// reading A0/A2

QByteArray buffer;
endRead=0;
  while(endRead==0) {

    readData.clear();
    control = 0;
    while(serialPort.isOpen()){ // READING BYTES FROM SERIAL PORT
        control += 1;
        //https://stackoverflow.com/questions/42576537/qt-serial-port-reading
        if(!serialPort.waitForReadyRead(200)) //block until new data arrives, dangerous, need a fix
             qDebug() << "Read error: " << serialPort.errorString() ;
        else{
            if (debug)
                 qDebug() << "New data available: " << serialPort.bytesAvailable() ;
            readData = serialPort.readAll();
            buffer.append(readData);

            if (debug)
                 qDebug() << readData;
            break;
        }
        if (control > 10){
             qDebug() << "Time out read error";
            return false;
        }
}
 if (buffer.endsWith("\x03"))
       endRead=1;
}

  QByteArray response;

  response.append(buffer[4]);
  response.append(buffer[5]);

  if(debug) qDebug() <<" response :" << response;

  if(response!="A0")
   {   qDebug() << "Error in Ultimus comunication, A2 code";
      return false;
  }else
  {//ui->dispenserResponse->setText("Success");

  }



// sending EOT

QByteArray eot;
eot[0]=0x04;

 output = serialPort.write(eot);
    if (debug)
        qDebug() <<"Log >> bytes written   : " <<eot<< " : operation : "<<eot;
    if(output == -1){
        qDebug() <<"Error write operation : "<<eot << " => " << serialPort.errorString();
        return false;
    }


//closing port


serialPort.close(); //closing serial port comunication
std::cout<<"Port closed"<<std::endl;

return true;
}


QByteArray Magrathea::RS232V_fb(QByteArray command)

{
    //Initialization of serial port
    QByteArray feedback;
    feedback="Error";
    bool debug = false;


     QByteArray readData;
     QByteArray writeData;
     QSerialPort serialPort;
     const QString serialPortName = "COM4"; //to modify according to the serial port used
     serialPort.setPortName(serialPortName);
     serialPort.setBaudRate(QSerialPort::Baud115200); // set BaudRate to 115200
     serialPort.setParity(QSerialPort::NoParity); //set Parity Bit to None
     serialPort.setStopBits(QSerialPort::OneStop); //set
     serialPort.setDataBits(QSerialPort::Data8); //DataBits to 8
     serialPort.setFlowControl(QSerialPort::NoFlowControl);
     serialPort.close();
     if (!serialPort.open(QIODevice::ReadWrite)) {
         std::cout<<"FAIL!!!!!"<<std::endl;
         qWarning("Failed to open port %s, error: %s",serialPortName.toLocal8Bit().constData(),serialPort.errorString().toLocal8Bit().constData());
         return feedback;
     }else {
         if (debug)
             std::cout<<"Port opened successfully"<<std::endl;
}

  // building command line



  //command=ui->dispenserCommand->text().toLatin1();

  QByteArray full_order;
  full_order[0] = 2;
  //qDebug() << command;

  int size_command_line;
  size_command_line=command.size();
  QByteArray order;
  QByteArray cs_temp;
  QByteArray cs;
  order=int_tohexQByteArray_UltimusV(size_command_line);

  for(int i=0;i<command.size();i++)
  order.append(command[i]);

  int checksum = 0;
  for(int i=0;i<order.size();i++)// evauating checksum quantity
  checksum -= order[i];

      cs_temp = int_tohexQByteArray_UltimusV(checksum & 0x000000ff);
      cs.clear();
      if(cs_temp.size() > 2){
          if (debug)
              qDebug() <<"here : "<<cs_temp.size()<<"  :  " << cs_temp ;
          cs = cs_temp.remove(0,(cs_temp.size()-2));
          if (debug)
              qDebug() <<"CS  :  "<<cs ;
      } else {
          cs = cs_temp;
          if (debug)
              qDebug() <<"CS  :  "<<cs ;
      }

  if(debug) qDebug() << order <<checksum << cs ;

  full_order.append(order);
  full_order.append(cs);
  full_order.append(QByteArrayLiteral("\x03"));

    writeData = QByteArrayLiteral("\x05"); //sending enquiry command
     long long int output = 0;
     output = serialPort.write(writeData);
     if (debug)
         qDebug() <<"Log >> bytes written   : " <<output<< " : operation : "<<writeData;
     if(output == -1){
         qDebug() <<"Error write operation : "<<writeData << " => " << serialPort.errorString();
         return feedback;
     }

// sending ENQ

QByteArray enq;
enq[0]=0x05;

 output = serialPort.write(enq);
    if (debug)
        qDebug() <<"Log >> bytes written   : " <<enq<< " : operation : "<<enq;
    if(output == -1){
        qDebug() <<"Error write operation : "<<enq << " => " << serialPort.errorString();
        return feedback;
    }

 // reading ACK
int endRead=0;
int control;
  while(endRead==0)
  {
    readData.clear();
    control = 0;
    while(serialPort.isOpen()){ // READING BYTES FROM SERIAL PORT
    control += 1;
    //https://stackoverflow.com/questions/42576537/qt-serial-port-reading
    if(!serialPort.waitForReadyRead(100)) //block until new data arrives, dangerous, need a fix
         qDebug() << "Read error: " << serialPort.errorString() ;
    else{
        if (debug)
             qDebug() << "New data available: " << serialPort.bytesAvailable() ;
        readData = serialPort.readAll();

        if (debug)
             qDebug() << readData;
        break;
    }
    if (control > 10){
         qDebug() << "Time out read error";
        return feedback;
    }
 }
    if (readData.endsWith("\x06"))
        endRead=1;
  }

//  serialPort.clear();


    // sending command


  output = serialPort.write(full_order);
  if (debug)
      qDebug() <<"Log >> bytes written   : " <<output<< " : operation : "<<full_order;
  if(output == -1){
      qDebug() <<"Error write operation : "<<full_order << " => " << serialPort.errorString();
      return feedback;
  }


  // reading A0/A2

QByteArray buffer;
endRead=0;

  while(endRead==0) {

   readData.clear();
   control = 0;
   while(serialPort.isOpen()){ // READING BYTES FROM SERIAL PORT
   control += 1;
   //https://stackoverflow.com/questions/42576537/qt-serial-port-reading
   if(!serialPort.waitForReadyRead(500)) //block until new data arrives, dangerous, need a fix
        qDebug() << "Read error: " << serialPort.errorString() ;
   else{
       if (debug)
            qDebug() << "New data available: " << serialPort.bytesAvailable() ;
       readData = serialPort.readAll();
buffer.append(readData);
       if (debug)
            qDebug() << readData << "buffer 1: " << buffer ;
       break;
   }
   if (control > 10){
        qDebug() << "Time out read error";
       return feedback;
   }
   }
   if (buffer.endsWith("\x03"))
       endRead=1;
  }

  QByteArray response;

  response.append(buffer[4]);
  response.append(buffer[5]);

  if(debug) qDebug() <<" response :" << response;

  if(response!="A0")
   {   qDebug() << "Error in Ultimus comunication, A2 code";
      return feedback;
  }

//   sending ACK

//   if (readData!="A0")
//       return feedback;
//   else {
    QByteArray ack;
    ack[0]=0x06;

     output = serialPort.write(ack);
        if (debug)
            qDebug() <<"Log >> bytes written   : " <<ack<< " : operation : "<<ack;
        if(output == -1){
            qDebug() <<"Error write operation : "<<ack << " => " << serialPort.errorString();
            return feedback;
        }
//   }
   // reading feedback

        buffer.clear();
        endRead=0;
      while(endRead==0) {


        readData.clear();
       control = 0;
       while(serialPort.isOpen()){ // READING BYTES FROM SERIAL PORT
       control += 1;
       if(!serialPort.waitForReadyRead(500)) //block until new data arrives, dangerous, need a fix
            qDebug() << "Read error: " << serialPort.errorString() ;
       else{
           if (debug)
                qDebug() << "New data available: " << serialPort.bytesAvailable() ;
           readData = serialPort.readAll();
        buffer.append(readData);
           if (debug)
                qDebug() << readData << "buffer 2:" << buffer;
           break;
       }
       if (control > 10){
            qDebug() << "Time out read error";
           return feedback;
           }
   }
       if (buffer.endsWith("\x03"))
       endRead=1;
}
 // sending EOT

 QByteArray eot;
 eot[0]=0x04;

  output = serialPort.write(eot);
  if (debug)
      qDebug() <<"Log >> bytes written   : " <<eot<< " : operation : "<<eot;
  if(output == -1){
      qDebug() <<"Error write operation : "<<eot << " => " << serialPort.errorString();
      return feedback;
        }

  //closing port


  serialPort.close(); //closing serial port comunication
  if (debug) qDebug() <<"Port closed";

feedback=buffer;
int fbSize=feedback.length();
feedback.remove(fbSize-3,3);
feedback.remove(0,3);

if(debug) qDebug() << feedback  << fbSize;

//ui->dispenserResponse->setText(feedback);
return feedback;


}


bool Magrathea::RS232V()
{
QByteArray command;
QByteArray response;
command.append(ui->dispenserCommand->text());
response.append(RS232V(command));
if(response=="error")
 {   qDebug() << "Error in sending command";
ui->dispenserResponse->setText("error");
    return false;
 }
 else
ui->dispenserResponse->setText(response);
return true;
}


bool Magrathea::RS232V_fb()

{
QByteArray command;
QByteArray response;
command.append(ui->dispenserCommand->text());
response.append(RS232V_fb(command));
if(response=="error")
 {   qDebug() << "Error in sending command";
ui->dispenserResponse->setText("error");
    return false;
 }
 else
ui->dispenserResponse->setText(response);
return true;
}

bool Magrathea::dispenseCycle()

{
    if(!RS232V("DI  "))
       { qDebug() << "Error in DI   command";
        return false;
    }
return true;
}


bool Magrathea::patternLine()

{
    if(X_stage_on==0 || Y_stage_on==0)
        return false;
bool debug=false;
    double length=100;
    double vel;
    double time;
    double deltaY=20;
    int move_state_X=1;
    QElapsedTimer timer;

    vel = PS90_GetPosFEx(Index,Axisid_X);
    long error = PS90_GetReadError(1);
    if (error != 0 ){ QMessageBox::critical(this, tr("Error"), tr("Error in PS90_GetPosFEx X Axis")); }

    error = PS90_MoveEx(Index,Axisid_X,-length,1);
    if (error != 0 ){ QMessageBox::critical(this, tr("Error"), tr("Error in PS90_MoveEx X Axis- need to add specification!!")); }
    timer.start();
    Sleep(500);

    if(!dispenseCycle())
    return false;
    time=length/vel-0.1*(length/vel);
    /*if (debug)*/ qDebug() << "velocidad" << vel << "tiempo" << time;

while (timer.elapsed()<time*1000) {if (debug) qDebug() << "time elapsed:" << timer.elapsed(); }
if(!dispenseCycle())
    return false;

    while(move_state_X!=0){
        move_state_X = PS90_GetMoveState(Index,Axisid_X);
        error = PS90_GetReadError(Index);
        if (error != 0 ){ QMessageBox::critical(this, tr("Error"), tr("Error in PS90_GetMoveState X Axis ")); }
//        if (debug) qDebug() << "estado de movimiento eje X" << move_state_X;
    }

    error = PS90_MoveEx(Index,Axisid_X,length,1);
    if (error != 0 ){ QMessageBox::critical(this, tr("Error"), tr("Error in PS90_MoveEx X Axis- need to add specification!!")); }
    error = PS90_MoveEx(Index,Axisid_Y,deltaY,1);
    if (error != 0 ){ QMessageBox::critical(this, tr("Error"), tr("Error in PS90_MoveEx X Axis- need to add specification!!")); }
    return true;
}


