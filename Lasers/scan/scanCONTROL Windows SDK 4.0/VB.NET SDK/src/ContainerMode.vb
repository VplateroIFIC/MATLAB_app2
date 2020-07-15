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

                    Console.WriteLine(Environment.NewLine & "----- Poll for rearranged container -----" & Environment.NewLine)
                    ContainerModeRearrangement()

                    Console.WriteLine(Environment.NewLine & "----- Poll for profile container -----" & Environment.NewLine)
                    ContainerModeProfile()

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

        Shared Sub ContainerModeRearrangement()

            Dim iRetValue As Integer
            Dim uiFieldCount As UInteger = 3
            Dim uiProfileCount As UInteger = 3
            Dim uiProfileCounter As UInteger = 0
            Dim uiInquiry As UInteger = 0
            Dim uiLostProfiles As UInteger = 0
            Dim usValue As UShort = 0
            Dim dTimeShutterOpen As Double = 0.0
            Dim dTimeShutterClose As Double = 0.0

            ' Calculate the bitfield for the resolution (e.g. if Resolution 160 the result must be 7; for 1280 the result must be 10)
            Dim dTempLog As Double = 1.0 / Math.Log(2.0)
            Dim uiResolutionBitField As UInteger = CUInt(Math.Floor((Math.Log(uiResolution) * dTempLog) + 0.5))

            'Check if sensor supports the container mode
            iRetValue = CLLTI.GetFeature(hLLT, CLLTI.INQUIRY_FUNCTION_REARRANGEMENT_PROFILE, uiInquiry)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature", iRetValue)

            End If

            If ((uiInquiry And &H80000000) = 0) Then
                Console.WriteLine("The connected scanCONTROL doesn't support the container mode")
                Return
            End If

            'Extract X and Z
            'Insert empty field for timestamp
            'Insert timestamp
            'calculation for the points per profile = Round(Log2(resolution))
            'Extract only 1th reflection
            Console.WriteLine("Set the rearrangement parameter")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_REARRANGEMENT_PROFILE, (CLLTI.CONTAINER_STRIPE_1 Or CLLTI.CONTAINER_DATA_Z Or
                                                                                                CLLTI.CONTAINER_DATA_X Or CLLTI.CONTAINER_DATA_EMPTYFIELD4TS Or
                                                                                                CLLTI.CONTAINER_DATA_TS Or CLLTI.CONTAINER_DATA_LSBF Or
                                                                                                (uiResolutionBitField << 12)))
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then

                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' Set the profile container size according to the given profile count
            Console.WriteLine("Set profile container size")
            iRetValue = CLLTI.SetProfileContainerSize(hLLT, 0, uiProfileCount)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetProfileContainerSize", iRetValue)
                Return
            End If

            'Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_CONTAINER_MODE, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            'Allocate buffersize according to transmitted data
            Dim abyContainerBuffer(uiResolution * 2 * uiFieldCount * uiProfileCount - 1) As Byte
            Dim abyTimestamp(16) As Byte

            'Sleep for a while to warm up the transfer
            System.Threading.Thread.Sleep(1000)


            'Poll one container
            iRetValue = CLLTI.GetActualProfile(hLLT, abyContainerBuffer, abyContainerBuffer.GetLength(0), CLLTI.TProfileConfig.CONTAINER, uiLostProfiles)
            If (iRetValue <> abyContainerBuffer.GetLength(0)) Then
                OnError("Error during GetActualProfile", iRetValue)
                Return
            End If

            Console.WriteLine("Container received")

            'Print the x/z data of the first 4 points of the transmitted profiles

            For iProfile As UInteger = 0 To uiProfileCount - 1 Step 1

                For iCurrentField As UInteger = 0 To 1

                    For iCurrentPointByte As UInteger = 0 To 6 Step 2
                        usValue = (CUShort(abyContainerBuffer((2 * iProfile * uiResolution * uiFieldCount) + (2 * iCurrentField * uiResolution) + (iCurrentPointByte))) << 8) + abyContainerBuffer((2 * iProfile * uiResolution * uiFieldCount) + (2 * iCurrentField * uiResolution) + (iCurrentPointByte + 1))
                        Console.WriteLine("Field: " & (iCurrentField + 1) & " Point: " & (iCurrentPointByte / 2) & ": Value - " & usValue)
                    Next

                Next
                Buffer.BlockCopy(abyContainerBuffer, (2 * (iProfile + 1) * uiResolution * uiFieldCount) - 16, abyTimestamp, 0, 16)
                CLLTI.Timestamp2TimeAndCount(abyTimestamp, dTimeShutterOpen, dTimeShutterClose, uiProfileCounter)
                Console.WriteLine("Profile Counter: " & uiProfileCounter)

            Next

            'Stop continous proifle transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_CONTAINER_MODE, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

        End Sub


        'Set the sensor to transmit profile container - in this case 10 profiles with the full data set
        'This reduces the necessary response time of the software

        Shared Sub ContainerModeProfile()

            Dim iRetValue As Integer
            Dim uiProfileCount As UInteger = 10
            Dim uiProfileCounter As UInteger = 0
            Dim uiInquiry As UInteger = 0
            Dim uiLostProfiles As UInteger = 0
            Dim dTimeShutterOpen As Double = 0.0
            Dim dTimeShutterClose As Double = 0.0

            Dim adValueX(uiResolution) As Double
            Dim adValueZ(uiResolution) As Double

            ' Calculate the bitfield for the resolution (e.g. if Resolution 160 the result must be 7; for 1280 the result must be 10)
            Dim dTempLog As Double = 1.0 / Math.Log(2.0)
            Dim uiResolutionBitField As UInteger = CUInt(Math.Floor((Math.Log(uiResolution) * dTempLog) + 0.5))

            'Check if sensor supports the container mode
            iRetValue = CLLTI.GetFeature(hLLT, CLLTI.INQUIRY_FUNCTION_REARRANGEMENT_PROFILE, uiInquiry)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature", iRetValue)

            End If

            If ((uiInquiry And &H80000000) = 0) Then
                Console.WriteLine("The connected scanCONTROL doesn't support the container mode")
                Return
            End If

            'calculation for the points per profile = Round(Log2(resolution)) 
            Console.WriteLine("Set the rearrangement parameter")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_REARRANGEMENT_PROFILE, uiResolutionBitField << 12)

            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then

                OnError("Error during SetFeature", iRetValue)
                Return
            End If

            ' Set the profile container size according to the given profile count
            Console.WriteLine("Set profile container size")
            iRetValue = CLLTI.SetProfileContainerSize(hLLT, 0, uiProfileCount)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetProfileContainerSize", iRetValue)
                Return
            End If

            'Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_CONTAINER_MODE, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

            'Allocate buffersize according to transmitted data
            Dim abyContainerBuffer(uiResolution * 64 * uiProfileCount - 1) As Byte
            Dim abyProfileBuffer(uiResolution * 64 - 1) As Byte
            Dim abyTimestamp(16) As Byte

            'Sleep for a while to warm up the transfer
            System.Threading.Thread.Sleep(1000)

            'Poll one container
            iRetValue = CLLTI.GetActualProfile(hLLT, abyContainerBuffer, abyContainerBuffer.GetLength(0), CLLTI.TProfileConfig.CONTAINER, uiLostProfiles)
            If (iRetValue <> abyContainerBuffer.GetLength(0)) Then
                OnError("Error during GetActualProfile", iRetValue)
                Console.WriteLine("iRetValue: " + iRetValue + " Bufferlength: " + abyContainerBuffer.GetLength(0))
                Return
            End If

            'Iterate over profiles 
            For iProfile As Integer = 0 To uiProfileCount - 1
                Buffer.BlockCopy(abyContainerBuffer, iProfile * uiResolution * 64, abyProfileBuffer, 0, abyProfileBuffer.GetLength(0))
                'Convert profile to x and z values
                iRetValue = CLLTI.ConvertProfile2Values(hLLT, abyProfileBuffer, uiResolution, CLLTI.TProfileConfig.PROFILE, tscanCONTROLType, 0, 1, Nothing, Nothing, Nothing, adValueX, adValueZ, Nothing, Nothing)
                If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                    OnError("Error during Converting Profiles", iRetValue)
                    Return
                End If

                If (((iRetValue And CLLTI.CONVERT_X) = 0) OrElse ((iRetValue And CLLTI.CONVERT_Z) = 0)) Then
                    OnError("Error during Converting of profile data", iRetValue)
                    Return
                End If

                For j As Integer = 0 To 3
                    Console.WriteLine("(" & adValueX(j) & ", " & adValueZ(j) & "), ")
                Next

                Buffer.BlockCopy(abyProfileBuffer, uiResolution * 64 - 16, abyTimestamp, 0, 16)
                CLLTI.Timestamp2TimeAndCount(abyTimestamp, dTimeShutterOpen, dTimeShutterClose, uiProfileCounter)
                Console.WriteLine("Profile Counter: " & uiProfileCounter)

            Next

            'Stop continous proifle transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_CONTAINER_MODE, 0)
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