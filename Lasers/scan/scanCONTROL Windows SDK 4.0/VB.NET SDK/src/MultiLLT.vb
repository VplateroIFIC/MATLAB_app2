Imports System
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Threading


Namespace VB

    Public Class VBscanCNONTROLSample

        ' Global variables
        Const MAX_INTERFACE_COUNT As Integer = 5
        Const Max_RESOLUTIONS As Integer = 6

        Public Shared uiResolution As UInteger = 0
        Public Shared uiResolution2 As UInteger = 0
        Public Shared hLLT As UInteger = 0
        Public Shared hLLT2 As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType
        Public Shared tscanCONTROLType2 As CLLTI.TScannerType

        Public Shared abyProfileBuffer As Byte()
        Public Shared abyProfileBuffer2 As Byte()

        Public Shared bProfileReceived As Boolean = False
        Public Shared bProfileReceived2 As Boolean = False
        Public Shared uiProfileDataSize As UInteger = 0
        Public Shared uiProfileDataSize2 As UInteger = 0



        ' Define an array with two AutoResetEvent WaitHandles.
        Shared hProfileEvent As AutoResetEvent = New AutoResetEvent(False)

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
            Dim uiShutterTime As UInteger = 100
            Dim uiIdleTime As UInteger = 122
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

            hLLT2 = CLLTI.CreateLLTDevice(CLLTI.TInterfaceType.INTF_TYPE_ETHERNET)
            If (hLLT2 <> 0) Then
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

            If (iInterfaceCount >= 2) Then
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

                target4 = auiInterfaces(1) And &HFF
                target3 = (auiInterfaces(1) And &HFF00) >> 8
                target2 = (auiInterfaces(1) And &HFF0000) >> 16
                target1 = (auiInterfaces(0) And &HFF000000) >> 24

                'Set the second IP adress
                Console.WriteLine("Select the device interface: " & target1 & "." & target2 & "." & target3 & "." & target4)
                iRetValue = CLLTI.SetDeviceInterface(hLLT2, auiInterfaces(1), 0)
                If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                    OnError("Error during SetDeviceInterface", iRetValue)
                    bOK = False
                End If

                If (bOK) Then
                    ' Connect to sensor with the device interface set before
                    Console.WriteLine("Connecting to scanCONTROL 1")
                    iRetValue = CLLTI.Connect(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then

                        OnError("Error during Connect", iRetValue)
                        bOK = False

                    Else
                        bConnected = True
                    End If
                End If

                If (bOK) Then
                    ' Connect to sensor with the device interface set before
                    Console.WriteLine("Connecting to scanCONTROL 2")
                    iRetValue = CLLTI.Connect(hLLT2)
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
                    Console.WriteLine("Get Device Name 1")
                    iRetValue = CLLTI.GetDeviceName(hLLT, sbDevName, sbDevName.Capacity, sbVenName, sbVenName.Capacity)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetDevName 1", iRetValue)
                        bOK = False
                    Else
                        Console.WriteLine(" - Devname: " & sbDevName.ToString & Environment.NewLine & " - Venname: " & sbVenName.ToString)
                    End If
                End If

                If (bOK) Then

                    ' Read the device name and vendor from scanner
                    Console.WriteLine("Get Device Name 2")
                    iRetValue = CLLTI.GetDeviceName(hLLT2, sbDevName, sbDevName.Capacity, sbVenName, sbVenName.Capacity)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetDevName 2", iRetValue)
                        bOK = False
                    Else
                        Console.WriteLine(" - Devname: " & sbDevName.ToString & Environment.NewLine & " - Venname: " & sbVenName.ToString)
                    End If
                End If

                If (bOK) Then

                    ' Get the scanCONTROL type and check if it is valid
                    Console.WriteLine("Get scanCONTROL type 1")
                    iRetValue = CLLTI.GetLLTType(hLLT, tscanCONTROLType)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetLLTType", iRetValue)
                        bOK = False
                    End If

                    If (iRetValue = CLLTI.GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED) Then
                        Console.WriteLine(" - Can't decode scanCONTROL type. Please contact Micro-Epsilon for a newer version of the LLT.dll.")
                    End If

                    If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 1 is a scanCONTROL27xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL25xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL25xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 1 is a scanCONTROL25xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL26xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL26xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 1 is a scanCONTROL26xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL29xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL29xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 1 is a scanCONTROL29xx")
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 1 is a scanCONTROL30xx")
                    Else
                        Console.WriteLine(" - The scanCONTROL 1 is a undefined type!" & Environment.NewLine & "Please contact Micro-Epsilon for a newer SDK!")
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

                If (bOK) Then

                    ' Get the scanCONTROL type and check if it is valid
                    Console.WriteLine("Get scanCONTROL type 2")
                    iRetValue = CLLTI.GetLLTType(hLLT2, tscanCONTROLType2)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetLLTType", iRetValue)
                        bOK = False
                    End If

                    If (iRetValue = CLLTI.GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED) Then
                        Console.WriteLine(" - Can't decode scanCONTROL type. Please contact Micro-Epsilon for a newer version of the LLT.dll.")
                    End If

                    If (tscanCONTROLType2 >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType2 <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 2 is a scanCONTROL27xx")
                    ElseIf (tscanCONTROLType2 >= CLLTI.TScannerType.scanCONTROL25xx_25 And tscanCONTROLType2 <= CLLTI.TScannerType.scanCONTROL25xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 2 is a scanCONTROL25xx")
                    ElseIf (tscanCONTROLType2 >= CLLTI.TScannerType.scanCONTROL26xx_25 And tscanCONTROLType2 <= CLLTI.TScannerType.scanCONTROL26xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 2 is a scanCONTROL26xx")
                    ElseIf (tscanCONTROLType2 >= CLLTI.TScannerType.scanCONTROL29xx_25 And tscanCONTROLType2 <= CLLTI.TScannerType.scanCONTROL29xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 2 is a scanCONTROL29xx")
                    ElseIf (tscanCONTROLType2 >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType2 <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL 2 is a scanCONTROL30xx")
                    Else
                        Console.WriteLine(" - The scanCONTROL 2 is a undefined type!" & Environment.NewLine & "Please contact Micro-Epsilon for a newer SDK!")
                    End If

                    ' Get all possible resolutions for connected sensor and save them in array 
                    Console.WriteLine("Get all possible resolutions")
                    iRetValue = CLLTI.GetResolutions(hLLT2, auiResolutions, auiResolutions.GetLength(0))
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetResolutions", iRetValue)
                        bOK = False
                    End If

                    ' Set the max. possible resolution
                    uiResolution2 = auiResolutions(0)
                End If


                ' Set scanner settings (for scanCONTROL 1) to valid parameters for this example                
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Set scanCONTROL Parameters -----" & Environment.NewLine)
                    Console.WriteLine("Set resolution 1 to " & uiResolution)
                    iRetValue = CLLTI.SetResolution(hLLT, uiResolution)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetResolution", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set BufferCount 1 to " & uiBufferCount)
                    iRetValue = CLLTI.SetBufferCount(hLLT, uiBufferCount)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetBufferCount", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set MainReflection 1 to " & uiMainReflection)
                    iRetValue = CLLTI.SetMainReflection(hLLT, uiMainReflection)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetMainReflection", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Packetsize 1 to " & uiPacketSize)
                    iRetValue = CLLTI.SetPacketSize(hLLT, uiPacketSize)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetPacketSize", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Profile config 1 to PROFILE")
                    iRetValue = CLLTI.SetProfileConfig(hLLT, CLLTI.TProfileConfig.PROFILE)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetProfileConfig", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set trigger 1 to internal")
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_TRIGGER, CLLTI.TRIG_INTERNAL)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_TRIGGER)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set shutter time 1 to " & uiShutterTime)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXPOSURE_TIME, uiShutterTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_SHUTTERTIME)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set idle time 1 to " & uiIdleTime)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IDLETIME, uiIdleTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_IDLETIME)", iRetValue)
                        bOK = False
                    End If
                End If

                ' Set scanner settings (for scanCONTROL 2) to valid parameters for this example
                If (bOK) Then
                    Console.WriteLine("Set resolution 2 to " & uiResolution2)
                    iRetValue = CLLTI.SetResolution(hLLT2, uiResolution2)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetResolution", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set BufferCount 2 to " & uiBufferCount)
                    iRetValue = CLLTI.SetBufferCount(hLLT2, uiBufferCount)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetBufferCount", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set MainReflection 2 to " & uiMainReflection)
                    iRetValue = CLLTI.SetMainReflection(hLLT2, uiMainReflection)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetMainReflection", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Packetsize 2 to " & uiPacketSize)
                    iRetValue = CLLTI.SetPacketSize(hLLT2, uiPacketSize)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetPacketSize", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Profile config 2 to PROFILE")
                    iRetValue = CLLTI.SetProfileConfig(hLLT2, CLLTI.TProfileConfig.PROFILE)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetProfileConfig", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set trigger 2 to internal")
                    iRetValue = CLLTI.SetFeature(hLLT2, CLLTI.FEATURE_FUNCTION_TRIGGER, CLLTI.TRIG_INTERNAL)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_TRIGGER)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set shutter time 2 to " & uiShutterTime)
                    iRetValue = CLLTI.SetFeature(hLLT2, CLLTI.FEATURE_FUNCTION_EXPOSURE_TIME, uiShutterTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_SHUTTERTIME)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set idle time 2 to " & uiIdleTime)
                    iRetValue = CLLTI.SetFeature(hLLT2, CLLTI.FEATURE_FUNCTION_IDLETIME, uiIdleTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_IDLETIME)", iRetValue)
                        bOK = False
                    End If
                End If



                ' Setup callback
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Setup Callback function and event -----" & Environment.NewLine)

                    Console.WriteLine("Register the callback 1")
                    ' Set the callback function
                    Dim gch As GCHandle = GCHandle.Alloc(New CLLTI.ProfileReceiveMethod(AddressOf ProfileEvent))

                    ' Register the callback 1
                    iRetValue = CLLTI.RegisterCallback(hLLT, CLLTI.TCallbackType.STD_CALL, DirectCast(gch.Target, CLLTI.ProfileReceiveMethod), hLLT)
                    'gch.Free()
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during RegisterCallback", iRetValue)
                        bOK = False
                    End If

                    'Register Callback 2
                    If (bOK) Then
                        Console.WriteLine("Register Callback 2")
                        iRetValue = CLLTI.RegisterCallback(hLLT2, CLLTI.TCallbackType.STD_CALL, DirectCast(gch.Target, CLLTI.ProfileReceiveMethod), hLLT2)
                    End If
                End If



                ' Main tasks in this example
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Get profiles with Callback from scanCONTROL -----" & Environment.NewLine)
                    GetProfiles_Callback()
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
                    iRetValue = CLLTI.DelDevice(hLLT2)
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



        ' Evalute received profiles via callback function
        Shared Sub GetProfiles_Callback()



            Dim iRetValue As Integer
            Dim adValueX(uiResolution) As Double
            Dim adValueZ(uiResolution) As Double
            Dim adValueX2(uiResolution2) As Double
            Dim adValueZ2(uiResolution2) As Double


            ' Allocate the profile buffer to the maximal profile size times the profile count
            ReDim abyProfileBuffer(uiResolution * 64)
            ReDim abyProfileBuffer2(uiResolution2 * 64)
            Dim abyTimestamp(16) As Byte

            ' Start continous profile transmission
            Console.WriteLine("Enable the measurement 1")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            Console.WriteLine("Enable the measurement 2")
            iRetValue = CLLTI.TransferProfiles(hLLT2, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            ' Wait for profile event (or timeout)
            Console.WriteLine("Wait for needed profiles")
            If (hProfileEvent.WaitOne(2000) <> True) Then
                Console.WriteLine("No profile received")
                Return
            End If

            ' Test the size of profile
            If (uiProfileDataSize = uiResolution * 64) Then
                Console.WriteLine("Profile size 1 is OK")
            Else
                Console.WriteLine("Profile size 1 is wrong")
                Return
            End If

            ' Test the size of profile
            If (uiProfileDataSize2 = uiResolution2 * 64) Then
                Console.WriteLine("Profile size 2 is OK")
            Else
                Console.WriteLine("Profile size 2 is wrong")
                Return
            End If

            ' Convert partial profile to x and z values
            Console.WriteLine("Converting of profile data from the first reflection")
            iRetValue = CLLTI.ConvertProfile2Values(hLLT, abyProfileBuffer, uiResolution, CLLTI.TProfileConfig.PROFILE, tscanCONTROLType,
                0, 1, Nothing, Nothing, Nothing, adValueX, adValueZ, Nothing, Nothing)
            If (((iRetValue & CLLTI.CONVERT_X) = 0) Or ((iRetValue & CLLTI.CONVERT_Z) = 0)) Then
                OnError("Error during Converting of profile data", iRetValue)
                Return
            End If

            ' Convert partial profile to x and z values
            Console.WriteLine("Converting of profile data from the first reflection")
            iRetValue = CLLTI.ConvertProfile2Values(hLLT2, abyProfileBuffer2, uiResolution2, CLLTI.TProfileConfig.PROFILE, tscanCONTROLType,
                0, 1, Nothing, Nothing, Nothing, adValueX2, adValueZ2, Nothing, Nothing)
            If (((iRetValue & CLLTI.CONVERT_X) = 0) Or ((iRetValue & CLLTI.CONVERT_Z) = 0)) Then
                OnError("Error during Converting of profile data", iRetValue)
                Return
            End If

            'Display x And z values
            Console.WriteLine("Profile data sensor 1")
            DisplayProfile(adValueX, adValueZ, uiResolution)
            Console.WriteLine("Profile data sensor 2")
            DisplayProfile(adValueX2, adValueZ2, uiResolution2)


            ' Extract the 16-byte timestamp from the profile buffer into timestamp buffer and display it
            Console.WriteLine("Timestamp sensor 1: ")
            Buffer.BlockCopy(abyProfileBuffer, 64 * uiResolution - 16, abyTimestamp, 0, 16)
            DisplayTimestamp(abyTimestamp)

            Console.WriteLine("Timestamp sensor 2: ")
            Buffer.BlockCopy(abyProfileBuffer2, 64 * uiResolution2 - 16, abyTimestamp, 0, 16)
            DisplayTimestamp(abyTimestamp)


            ' Stop continous profile transmission
            Console.WriteLine("Disable the measurement 1")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            Console.WriteLine("Disable the measurement 2")
            iRetValue = CLLTI.TransferProfiles(hLLT2, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

        End Sub


        ' Callback function which copies the received data into the buffer and sets an event after the specified profiles
        Shared Sub ProfileEvent(ByVal data As IntPtr, uiSize As UInteger, uiUserData As UInteger)

            If (uiSize > 0) Then
                If (uiUserData = hLLT) Then
                    ' If the needed profile count not arrived: copy the new Profile in the buffer and increase the recived buffer count
                    uiProfileDataSize = uiSize
                    ' Kopieren des Unmanaged Datenpuffers (data) in die Anwendung
                    Marshal.Copy(data, abyProfileBuffer, 0, uiSize)
                    bProfileReceived = True
                End If

                If (uiUserData = hLLT2) Then
                    ' If the needed profile count not arrived: copy the new Profile in the buffer and increase the recived buffer count
                    uiProfileDataSize2 = uiSize
                    ' Kopieren des Unmanaged Datenpuffers (data) in die Anwendung
                    Marshal.Copy(data, abyProfileBuffer2, 0, uiSize)
                    bProfileReceived2 = True
                End If

                If (bProfileReceived = True And bProfileReceived2 = True) Then
                    ' If the needed profile count is arrived: set the event
                    hProfileEvent.Set()

                End If
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
            Dim uiProfileCount As UInteger = 0UI

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