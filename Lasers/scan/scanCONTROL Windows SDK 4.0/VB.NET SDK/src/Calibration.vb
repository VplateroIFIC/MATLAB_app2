Imports System
Imports System.Collections.Generic
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Threading

Namespace VB

    Public Class VBscanCNONTROLSample

        ' Global variables
        Const MAX_INTERFACE_COUNT As Integer = 5
        Const Max_RESOLUTIONS As Integer = 6

        Public Shared uiResolution As UInteger = 0
        Public Shared hLLT As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType

        Shared Sub Main()
            scanCONTROL_Sample()
        End Sub

        Shared Sub scanCONTROL_Sample()
            Dim auiInterfaces(MAX_INTERFACE_COUNT - 1) As UInteger
            Dim auiResolutions(Max_RESOLUTIONS - 1) As UInteger

            Dim sbDevName As StringBuilder = New StringBuilder(100)
            Dim sbVenName As StringBuilder = New StringBuilder(100)

            Dim uiBufferCount As UInteger = 3
            Dim uiPacketSize As UInteger = 320

            Dim iInterfaceCount As Integer = 0
            Dim uiShutterTime As UInteger = 100
            Dim uiIdleTime As UInteger = 900
            Dim iRetValue As Integer
            Dim bOK As Boolean = True
            Dim bConnected As Boolean = False
            Dim cki As ConsoleKeyInfo

            hLLT = 0
            uiResolution = 0

            Console.WriteLine("----- Connect to scanCONTROL -----" & Environment.NewLine)

            ' Create an Ethernet Device -> returns handle to LLT device
            hLLT = CLLTI.CreateLLTDevice(CLLTI.TInterfaceType.INTF_TYPE_ETHERNET)
            If (hLLT <> 0) Then
                Console.WriteLine("CreateLLTDevice OK")
            Else
                Console.WriteLine("Error during CreateLLTDevice" & Environment.NewLine)
            End If

            ' Gets the available interfaces from the scanCONTROL handle
            iInterfaceCount = CLLTI.GetDeviceInterfacesFast(hLLT, auiInterfaces, auiInterfaces.GetLength(0))
            If (iInterfaceCount <= 0) Then
                Console.WriteLine("FAST: There is no scanCONTROL connected")
            ElseIf (iInterfaceCount = 1) Then
                Console.WriteLine("FAST: There is 1 scanCONTROL connected ")
            Else
                Console.WriteLine("FAST: There are " & iInterfaceCount & " scanCONTROL's connected")
            End If

            If (iInterfaceCount >= 1) Then
                Dim target4 As UInteger = auiInterfaces(0) And &HFF
                Dim target3 As UInteger = (auiInterfaces(0) And &HFF00) >> 8
                Dim target2 As UInteger = (auiInterfaces(0) And &HFF0000) >> 16
                Dim target1 As UInteger = (auiInterfaces(0) And &HFF000000) >> 24

                ' Set the first IP address detected by GetDeviceInterfacesFast to handle
                Console.WriteLine("Select the device interface: " & target1 & "." & target2 & "." & target3 & "." & target4)
                iRetValue = CLLTI.SetDeviceInterface(hLLT, auiInterfaces(0), 0)
                If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                    OnError("Error during SetDeviceInterface", iRetValue)
                    bOK = False
                End If

                If (bOK) Then
                    ' Connect to sensor with the device interface set before
                    Console.WriteLine("Connecting to scanCONTROL")
                    iRetValue = CLLTI.Connect(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then

                        OnError("Error during Connect", iRetValue)
                        bOK = False

                    Else
                        bConnected = True
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Get scanCONTROL Info -----" & Environment.NewLine)
                    ' Read the device name and vendor from scanner
                    Console.WriteLine("Get Device Name")
                    iRetValue = CLLTI.GetDeviceName(hLLT, sbDevName, sbDevName.Capacity, sbVenName, sbVenName.Capacity)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetDevName", iRetValue)
                        bOK = False
                    Else
                        Console.WriteLine(" - Devname: " & sbDevName.ToString & Environment.NewLine & " - Venname: " & sbVenName.ToString)
                    End If
                End If

                If (bOK) Then

                    ' Get the scanCONTROL type and check if it is valid
                    Console.WriteLine("Get scanCONTROL type")
                    iRetValue = CLLTI.GetLLTType(hLLT, tscanCONTROLType)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetLLTType", iRetValue)
                        bOK = False
                    End If

                    If (iRetValue = CLLTI.GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED) Then
                        Console.WriteLine(" - Can't decode scanCONTROL type. Please contact Micro-Epsilon for a newer version of the LLT.dll.")
                    End If

                    If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL27xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL25xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL25xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL25xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL26xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL26xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL26xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL29xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL29xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL29xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL30xx")
                    Else
                        Console.WriteLine(" - The scanCONTROL is a undefined type!" & Environment.NewLine & "Please contact Micro-Epsilon for a newer SDK!")
                    End If

                    ' Get all possible resolutions for connected sensor and save them in array 
                    Console.WriteLine("Get all possible resolutions")
                    iRetValue = CLLTI.GetResolutions(hLLT, auiResolutions, auiResolutions.GetLength(0))
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetResolutions", iRetValue)
                        bOK = False
                    End If

                    ' Set the max. possible resolution
                    uiResolution = auiResolutions(0)
                End If

                ' Set scanner settings to valid parameters for this example
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Set scanCONTROL Parameters -----" & Environment.NewLine)
                    Console.WriteLine("Set resolution to " & uiResolution)
                    iRetValue = CLLTI.SetResolution(hLLT, uiResolution)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetResolution", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set BufferCount to " & uiBufferCount)
                    iRetValue = CLLTI.SetBufferCount(hLLT, uiBufferCount)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetBufferCount", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Packetsize to " & uiPacketSize)
                    iRetValue = CLLTI.SetPacketSize(hLLT, uiPacketSize)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetPacketSize", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Profile config to Container")
                    iRetValue = CLLTI.SetProfileConfig(hLLT, CLLTI.TProfileConfig.CONTAINER)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetProfileConfig", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set trigger to internal")
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_TRIGGER, CLLTI.TRIG_INTERNAL)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_TRIGGER)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set shutter time to " & uiShutterTime)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXPOSURE_TIME, uiShutterTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_SHUTTERTIME)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set idle time to " & uiIdleTime)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IDLETIME, uiIdleTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_IDLETIME)", iRetValue)
                        bOK = False
                    End If
                End If

                ' Main tasks in this example
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Set Calibration -----" & Environment.NewLine)
                    Calibration()
                End If

                Console.WriteLine(Environment.NewLine & "----- Disconnect from scanCONTROL -----" & Environment.NewLine)

                If (bConnected) Then
                    ' Disconnect from the sensor
                    Console.WriteLine("Disconnect the scanCONTROL")
                    iRetValue = CLLTI.Disconnect(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during Disconnect", iRetValue)
                    End If
                End If

                If (bConnected) Then
                    ' Free ressources
                    Console.WriteLine("Delete the scanCONTROL instance")
                    iRetValue = CLLTI.DelDevice(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during Delete", iRetValue)
                    End If
                End If
            End If

            'Wait for a keyboard hit
            While (True)
                cki = Console.ReadKey()
                If (cki.KeyChar <> "0") Then
                    Exit While
                End If
            End While

        End Sub

        'Set Calibration
        Shared Sub Calibration()

            'Sensor parameters have to be adjusted for sensor type - see Config Tools Manual
            Dim offset As Double = 65.0
            Dim scaling As Double = 0.001

            'Center of rotation and angle
            Dim center_x As Double = 0.0
            Dim center_z As Double = offset
            Dim angle As Double = -2.0

            'Coordinate system is shifted by
            Dim shift_x As Double = -2.0
            Dim shift_z As Double = -2.0

            Console.WriteLine("Read Calibration")
            ReadCalibration(offset, scaling)

            Console.WriteLine("Reset Calibration 1")
            ResetCustomCalibration()

            Console.WriteLine("Read Calibration")
            ReadCalibration(offset, scaling)

            'Console.WriteLine("Set Calibration 1")
            'SetCustomCalibration(center_x, center_z, angle, shift_x, shift_z, offset, scaling);

            'Console.WriteLine("Read Calibration")
            'ReadCalibration(offset, scaling)

            'Console.WriteLine("Reset Calibration 2")
            'ResetCustomCalibration2()

            'Console.WriteLine("Read Calibration")
            'ReadCalibration(offset, scaling)

            Console.WriteLine("Set Calibration 2")
            SetCustomCalibration2(center_x, center_z, angle, shift_x, shift_z, offset, scaling)

            Console.WriteLine("Read Calibration")
            ReadCalibration(offset, scaling)

            Console.WriteLine("Save calibration permanently")
            CLLTI.SaveGlobalParameter(hLLT)

        End Sub

        'Function to be used for sensors with Firmware >= v43
        Shared Sub SetCustomCalibration2(cX As Double, cZ As Double, angle As Double, sX As Double, sZ As Double, offset As Double, scaling As Double)

            Dim iretValue As Integer
            Dim tmp As UInteger
            Dim rotate_angle As Double = angle
            Dim PI As Double = Math.PI
            Dim xTrans As Double = -sX
            Dim zTrans As Double = offset - sZ

            'Read current state of invert_x and invert_z from sensor
            iretValue = CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_PROFILE_PROCESSING, tmp)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature(FEATURE_FUNCTION_PROFILE_PROCESSING)", iretValue)
            End If

            Dim uiInvertX As UInteger = (tmp And CLLTI.PROC_FLIP_POSITION) >> 7
            Dim uiInvertZ As UInteger = (tmp And CLLTI.PROC_FLIP_DISTANCE) >> 6

            'invert angle if necessary 
            If (uiInvertX <> uiInvertZ) Then
                rotate_angle = -angle
            End If

            Dim sinus As Double = Math.Sin(rotate_angle * PI / 180)
            Dim cosinus As Double = Math.Cos(rotate_angle * PI / 180)

            'rotate angle
            If (rotate_angle < 0) Then
                rotate_angle = Math.Floor(65536 + rotate_angle / 0.01 + 0.5)

            Else
                rotate_angle = Math.Floor(rotate_angle / 0.01 + 0.5)

            End If

            'rotation center 1 for rotating
            Dim x1 As Double = cX / scaling + 32768
            Dim z1 As Double = (cZ - offset) / scaling + 32768

            'rotation center 2 for translating
            Dim x2 As Double = xTrans / scaling + 32768
            Dim z2 As Double = 65536 - ((zTrans - offset) / scaling + 32768)

            'Calculate the combined rotation center
            Dim x3 As Double = x1 + (x2 - 32768) * cosinus + (z2 - 32768) * sinus
            Dim z3 As Double = z1 + (z2 - 32768) * cosinus - (x2 - 32768) * sinus
            xTrans = Math.Floor(x3 + 0.5)
            zTrans = Math.Floor(z3 + 0.5)

            'Saturation 
            If (xTrans < 0) Then
                xTrans = 0
            ElseIf (xTrans > 65535) Then
                xTrans = 65535
            End If

            If (zTrans < 0) Then
                zTrans = 0
            ElseIf (zTrans > 65535) Then
                zTrans = 65535
            End If

            If (rotate_angle < 0) Then
                rotate_angle = 0
            ElseIf (rotate_angle > 65535) Then
                rotate_angle = 65535
            End If

            ' Compute register values
            Dim calib2 As UInteger = ((CUInt(xTrans << 16)) + CUInt(zTrans))
            Dim calib3 As UInteger = CUInt(rotate_angle)

            'Write Calibration to Sensor
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_0, &H5000004UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 0", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_1, &H8000080UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 1", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_2, calib2)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 2", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_3, calib3)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 3", iretValue)
            End If

        End Sub

        Shared Sub ReadCalibration(offset As Double, scaling As Double)

            Dim tmp As UInteger = 0
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_0, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_0: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_1, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_1: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_2, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_2: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_3, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_3: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_4, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_4: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_5, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_5: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_6, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_6: {0:X8}", tmp)
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_7, tmp)
            Console.WriteLine("FEATURE_FUNCTION_CALIBRATION_7: {0:X8}", tmp)
            Console.WriteLine("")

        End Sub

        Shared Sub ResetCustomCalibration()

            Dim iretValue As Integer
            'Deactivate Calibration
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_0, &H0UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 0", iretValue)
            End If
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_1, &H0UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 1", iretValue)
            End If

            'Reset Calibration registers
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_2, &H0UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 2", iretValue)
            End If
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CALIBRATION_3, &H0UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Activation 3", iretValue)
            End If
        End Sub


        ' Display the error text
        Shared Sub OnError(strErrorTxt As String, iErrorValue As Integer)

            Dim acErrorString(200) As Byte

            Console.WriteLine(strErrorTxt)
            If (CLLTI.TranslateErrorValue(hLLT, iErrorValue, acErrorString, acErrorString.GetLength(0)) _
                                            >= CLLTI.GENERAL_FUNCTION_OK) Then
                Console.WriteLine(System.Text.Encoding.ASCII.GetString(acErrorString, 0, acErrorString.GetLength(0)))
            End If
        End Sub

    End Class

End Namespace