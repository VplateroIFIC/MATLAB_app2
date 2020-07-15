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

        'TOCHECK: STATTHREAD
        Shared Sub Main()
            scanCONTROL_Sample()
        End Sub

        Shared Sub scanCONTROL_Sample()

            Dim auiInterfaces(MAX_INTERFACE_COUNT - 1) As UInteger
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

            ' Create an Ethernet Device -> returns handle to LLT device
            hLLT = CLLTI.CreateLLTDevice(CLLTI.TInterfaceType.INTF_TYPE_ETHERNET)
            If (hLLT <> 0) Then
                Console.WriteLine("CreateLLTDevice OK")
            Else
                Console.WriteLine("Error during CreateLLTDevice" & Environment.NewLine)
            End If

            Console.WriteLine("----- Connect to scanCONTROL -----" & Environment.NewLine)


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
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_TRIGGER, CLLTI.TRIG_EXT_ACTIVE)
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
                Console.WriteLine(Environment.NewLine & "----- Poll from scanCONTROL via Ethernet -----" & Environment.NewLine)
                SoftwareTrigger()
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

        ' Evalute reveived profiles in polling mode
        Shared Sub SoftwareTrigger()

            Dim iRetValue As Integer
            Dim uiLostProfiles As UInteger = 0
            Dim adValueX(uiResolution - 1) As Double
            Dim adValueZ(uiResolution - 1) As Double
            Dim uiInquiry As UInteger = 0
            Dim noProfilesReceived As Boolean = True

            ' Allocate the profile buffer to the maximal profile size times the profile count
            Dim abyProfileBuffer(uiResolution * 64 - 1) As Byte
            Dim abyTimestamp(16) As Byte

            ' Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            ' Sleep for a while to warm up the transfer
            System.Threading.Thread.Sleep(1000)

            'Software trigger - do not use for highspeed applications
            Console.WriteLine("Send software trigger")
            CLLTI.TriggerProfile(hLLT)

            ' Trigger one profile
            Do While (noProfilesReceived)
                iRetValue = CLLTI.GetActualProfile(hLLT, abyProfileBuffer, abyProfileBuffer.GetLength(0) - 1, CLLTI.TProfileConfig.PROFILE, uiLostProfiles)
                If (iRetValue <> abyProfileBuffer.GetLength(0)) Then
                    If (iRetValue = CLLTI.ERROR_PROFTRANS_NO_NEW_PROFILE) Then
                        noProfilesReceived = True
                    Else
                        OnError("Error during GetActualProfile", iRetValue)
                        Return
                    End If
                Else
                    noProfilesReceived = False
                    Console.WriteLine("Profile received")
                End If
            Loop



            ' Convert profile to x and z values
            Console.WriteLine("Converting of profile data from the first reflection")
            iRetValue = CLLTI.ConvertProfile2Values(hLLT, abyProfileBuffer, uiResolution, CLLTI.TProfileConfig.PROFILE, tscanCONTROLType,
              0, 1, Nothing, Nothing, Nothing, adValueX, adValueZ, Nothing, Nothing)
            If (((iRetValue & CLLTI.CONVERT_X) = 0) Or ((iRetValue & CLLTI.CONVERT_Z) = 0)) Then
                OnError("Error during Converting of profile data", iRetValue)
                Return
            End If
            ' Display x and z values
            DisplayProfile(adValueX, adValueZ, uiResolution)

            ' Extract the 16-byte timestamp from the profile buffer into timestamp buffer and display it
            Buffer.BlockCopy(abyProfileBuffer, 64 * uiResolution - 16, abyTimestamp, 0, 16)
            DisplayTimestamp(abyTimestamp)


            ' Stop continous profile transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

        End Sub

        ' Display the X/Z-Data of one profile
        Shared Sub DisplayProfile(adValueX As Double(), adValueZ As Double(), uiResolution As UInteger)

            Dim iNumberSize As Integer = 0
            For i As Integer = 0 To uiResolution - 1
                ' Prints the X- and Z-values
                iNumberSize = adValueX(i).ToString().Length
                Console.Write(Environment.NewLine & "Profiledata (" & i & "): X = " & adValueX(i).ToString())

                Do Until iNumberSize = 8
                    Console.Write(" ")
                    iNumberSize += 1
                Loop

                iNumberSize = adValueZ(i).ToString().Length
                Console.Write(" Z = " & adValueZ(i).ToString())

                Do Until iNumberSize = 8
                    Console.Write(" ")
                    iNumberSize += 1
                Loop

                ' Wait for display
                If (i Mod 8 = 0) Then
                    System.Threading.Thread.Sleep(10)
                End If
            Next
            Console.WriteLine("")
        End Sub

        ' Display the timestamp
        Shared Sub DisplayTimestamp(abyTimestamp As Byte())

            Dim dShutterOpen As Double = 0.0
            Dim dShutterClose As Double = 0.0
            Dim uiProfileCount As UInteger = 0

            ' Decode the timestamp
            CLLTI.Timestamp2TimeAndCount(abyTimestamp, dShutterOpen, dShutterClose, uiProfileCount)
            Console.WriteLine("ShutterOpen: " & dShutterOpen & " ShutterClose: " & dShutterClose)
            Console.WriteLine("ProfileCount: " & uiProfileCount)
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