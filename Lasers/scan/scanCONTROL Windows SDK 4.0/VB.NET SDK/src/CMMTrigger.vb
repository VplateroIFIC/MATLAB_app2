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

        Public Shared uiShutterTime As UInteger = 100
        Public Shared uiIdleTime As UInteger = 900

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
                Console.WriteLine(Environment.NewLine & "----- Show CMM Trigger functionality -----" & Environment.NewLine)
                CMMTrigger()
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

        ' Shows the configuration for using the sensor with a CMM trigger environment 
        Shared Sub CMMTrigger()

            Dim iRetValue As Integer
            Dim uiLostProfiles As UInteger = 0
            Dim uiInquiryCmmTrigger As UInteger = 0
            Dim uiInterfaceFuntionValue As UInteger = 0
            Dim uiIncounter As UInteger = 0
            Dim uiCmmCount As UInteger = 0
            Dim iCmmTrigger As Integer = 0
            Dim iCmmActive As Integer = 0

            ' Allocate the profile buffer to the maximal profile size times the profile count
            Dim abyProfileBuffer(uiResolution * 64 - 1) As Byte
            Dim abyTimestamp(16) As Byte

            'Check if 27xx or 26/29xx series and set the correct RS422 register
            If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then
                uiInterfaceFuntionValue = CLLTI.RS422_INTERFACE_FUNCTION_CMM_TRIGGER_27xx
            Else
                uiInterfaceFuntionValue = CLLTI.RS422_INTERFACE_FUNCTION_CMM_TRIGGER
            End If

            'Check if connected scanCONTROL is CMM enabled
            Console.WriteLine("Test the scanCONTROL for support of the Cmm-Trigger feature")
            iRetValue = CLLTI.GetFeature(hLLT, CLLTI.INQUIRY_FUNCTION_CMM_TRIGGER, uiInquiryCmmTrigger)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature", iRetValue)
                Return
            End If

            'Set the RS422 interface to CMM trigger
            Console.WriteLine("Set Digital IO to 'cmm trigger'")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_DIGITAL_IO, uiInterfaceFuntionValue)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            'set the mark space ratio
            Console.WriteLine("Set the CmmTrigger configuration: mark space ratio 1:1")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CMM_TRIGGER, &H401)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' set the skew correction
            Console.WriteLine("Set the CmmTrigger configuration: skew correction 2us")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CMM_TRIGGER, &H801)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' set the output port
            Console.WriteLine("Set the CmmTrigger configuration: output port 1")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CMM_TRIGGER, &HC00)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' set the trigger divisor
            Console.WriteLine("Set the CmmTrigger configuration: Divisor  1")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_CMM_TRIGGER, &H1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            ' Sleep for a while to warm up the transfer
            System.Threading.Thread.Sleep(1000)

            ' Get the next transmitted profile
            iRetValue = CLLTI.GetActualProfile(hLLT, abyProfileBuffer, abyProfileBuffer.GetLength(0), CLLTI.TProfileConfig.PROFILE, uiLostProfiles)
            If (iRetValue <> abyProfileBuffer.GetLength(0)) Then
                OnError("Error during GetActualProfile", iRetValue)
                Return
            End If
            Console.WriteLine("Profile received")


            ' Extract the 16-byte timestamp from the profile buffer into timestamp buffer and display it
            Buffer.BlockCopy(abyProfileBuffer, 64 * uiResolution - 16, abyTimestamp, 0, 16)
            Console.WriteLine("Read CMM Values from Timestamp:")
            CLLTI.Timestamp2CmmTriggerAndInCounter(abyTimestamp, uiIncounter, iCmmTrigger, iCmmActive, uiCmmCount)
            Console.WriteLine("- InCounter: " & uiIncounter & Environment.NewLine & "- CmmTriggerCounter: " & uiCmmCount)
            If (iCmmTrigger = 1) Then
                Console.WriteLine("- CMM trigger impulse: true")
            Else
                Console.WriteLine("- CMM trigger impulse: false")
            End If

            If (iCmmActive = 1) Then
                Console.WriteLine("- CMM trigger active: true")
            Else
                Console.WriteLine("- CMM trigger active: false")
            End If


            ' Stop continous profile transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
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