#ifndef GLUE_DISPENSER_H
#define GLUE_DISPENSER_H

#include <QWidget>
#include <Magrathea.h>



class glue_dispenser : public Magrathea
{
public:
    glue_dispenser();
    ~glue_dispenser();

protected slots:

    bool RS232V(QByteArray command);
    bool RS232V();
    QByteArray RS232V_fb(QByteArray command);
    bool RS232V_fb();
    bool dispenser_init();
    bool dispenser_mode();
    bool dispenser_pressure();
    bool dispenser_pressureUnits();
    bool dispenser_time();
    bool dispenser_vacuum();
//    bool patternLine();
    bool dispenseCycle();

};

#endif // GLUE_DISPENSER_H
