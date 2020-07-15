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

        Public Shared uiReceivedProfileCount As UInteger = 0
        Public Shared uiNeededProfileCount As UInteger = 10

        Public Shared uiResolution As UInteger = 0
        Public Shared hLLT As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType

        Public Shared uiShutterTime As UInteger = 100
        Public Shared uiIdleTime As UInteger = 900
        Public Shared m_toggle As Integer = 0

        Public Shared auiInterfaces(MAX_INTERFACE_COUNT) As UInteger

        'TOCHECK: STATTHREAD
        Shared Sub Main()
            scanCONTROL_Sample()
        End Sub

        Shared Sub scanCONTROL_Sample()

            'Dim auiInterfaces(MAX_INTERFACE_COUNT - 1) As UInteger
            Dim auiResolutions(Max_RESOLUTIONS - 1) As UInteger

            Dim sbDevName As StringBuilder = New StringBuilder(100)
            Dim sbVenName As StringBuilder = New StringBuilder(100)

            Dim uiBufferCount As UInteger = 20
            Dim uiMainReflection As UInteger = 0
            Dim uiPacketSize As UInteger = 1024

            Dim iInterfaceCount As Integer = 0
            Dim iRetValue As Integer
            Dim bOK As Boolean = True
            Dim bConnected As Boolean = False
            Dim cki As ConsoleKeyInfo


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
            Console.WriteLine(iInterfaceCount)
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
                    Console.WriteLine("\n----- Get scanCONTROL Info -----" & Environment.NewLine)
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
                    Console.WriteLine("Set MainReflection to " & uiMainReflection)
                    iRetValue = CLLTI.SetMainReflection(hLLT, uiMainReflection)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetMainReflection", iRetValue)
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
                    Console.WriteLine("Set Profile config to PROFILE")
                    iRetValue = CLLTI.SetProfileConfig(hLLT, CLLTI.TProfileConfig.PROFILE)
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

            ' Main task for this example
            If (bOK) Then
                Console.WriteLine(Environment.NewLine & "----- Set Peak Filter -----" & Environment.NewLine)
                SetPeakFilter()
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



            'Wait for a keyboard hit
            While (True)
                cki = Console.ReadKey()
                If (cki.KeyChar <> "0") Then
                    Exit While
                End If
            End While

        End Sub

        ' Set peak Filter
        Shared Sub SetPeakFilter()

            Dim iRetValue As Integer
            Dim min_width As UShort = 15
            Dim max_width As UShort = 256
            Dim min_intensity As UShort = 65
            Dim max_intensity As UShort = 986

            'Since LLT.dll version 3.7.x.x & scanCONTROL firmware v43 this method is prefered 
            'Readout of currently set values also possible with GetFeature

            'Set width
            'iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_PEAKFILTER_WIDTH, (CUInt(max_width) << 16) + min_width)
            'If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
            '    OnError("Error during setting PeakFilter", iRetValue)
            '    Return
            'End If

            ''Set intensity
            'iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_PEAKFILTER_HEIGHT, (CUInt(max_intensity) << 16) + min_intensity)
            'If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
            '    OnError("Error during setting PeakFilter", iRetValue)
            '    Return
            'End If

            ''Activate settings
            'iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXTRA_PARAMETER, 0)
            'If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
            '    OnError("Error during ExtraParameter", iRetValue)
            '    Return
            'End If

            Console.WriteLine("Write Peak filter: " & Environment.NewLine & " - Min width: " & min_width & Environment.NewLine & " - Max width: " & max_width & Environment.NewLine & " - Min intensity: " & min_intensity & Environment.NewLine & " - Max intensity: " & max_intensity)

            ' Set PeakFilters if firmware < v43
            iRetValue = SetPeakValues(min_width, max_width, min_intensity, max_intensity)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during setting peak values", iRetValue)
            End If

        End Sub

        Shared Function SetPeakValues(min_width As UShort, max_width As UShort, min_intensity As UShort, max_intensity As UShort) As Integer

            reset_command_list()
            write_value(max_width)
            write_value(min_width)
            write_value(max_intensity)
            write_value(min_intensity)
            end_command_list()

            Return CLLTI.GENERAL_FUNCTION_OK
        End Function

        'Write command for sequenciell register
        Shared Sub write_command(command As UInteger, data As UInteger)

            CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXTRA_PARAMETER, (command << 9) + (m_toggle << 8) + data)

            If (m_toggle = 1) Then
                m_toggle = 0
            Else
                m_toggle = 1
            End If
        End Sub

        'Write value in sequenciell register
        Shared Sub write_value(value As UShort)

            write_command(1, Math.Floor(value / 256))
            write_command(1, (value Mod 256))
        End Sub

        'Reset seq register
        Shared Sub reset_command_list()

            write_command(0, 0)
            write_command(0, 0)
        End Sub

        'End writing to seq register
        Shared Sub end_command_list()
            write_command(0, 0)
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