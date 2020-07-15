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
        Public Shared hLLT As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType
        Public Shared tPartialProfile As CLLTI.TPartialProfile
        Public Shared abyProfileBuffer As Byte()

        Public Shared bProfileReceived As UInteger = 0
        Public Shared uiNeededProfileCount As UInteger = 5001
        Public Shared uiProfileDataSize As UInteger = 0
        Public Shared raster_x As Double = 0
        Public Shared raster_z As Double = 0
        Public Shared uiPacketSize As UInteger = 1024
        Public Shared uiProfilecountStart As UInteger = 0
        Public Shared dShutteropenStart As Double = 0


        ' Define an array with two AutoResetEvent WaitHandles.
        Shared hProfileEvent As AutoResetEvent = New AutoResetEvent(False)

        'TOCHECK: STATTHREAD
        Shared Sub Main()
            scanCONTROL_Sample()
        End Sub

        Shared Sub scanCONTROL_Sample()
            Dim auiInterfaces(MAX_INTERFACE_COUNT - 1) As UInteger


            Dim sbDevName As StringBuilder = New StringBuilder(100)
            Dim sbVenName As StringBuilder = New StringBuilder(100)
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
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL30xx")
                        raster_x = 1.5625
                        raster_z = 200.0 / 1088.0
                    Else
                        Console.WriteLine(" - The scanCONTROL is not a scanCONTROL30xx!\n")
                        bOK = False
                    End If

                End If

                'Load UserMode 0 and set settings to default
                If (bOK) Then
                    Console.WriteLine("Load UserMode 0 to set the settings to default")
                    iRetValue = CLLTI.ReadWriteUserModes(hLLT, 0, 0)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetResolution", iRetValue)
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

                ' Main tasks in this example
                If (bOK) Then
                    ConfigureSensorForHighSpeed()
                End If

                If (bOK) Then
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


        Shared Sub ConfigureSensorForHighSpeed()

            'The maximum profile frequency that can be reached by scanCONTROL 30xx sensors Is limited by several factors.
            'Used Measuring field / Region of Interest (ROI) on the sensor matrix
            'Shutter time / Idle time
            'Number of points per profile
            'Data transmission type (single profile / container mode)
            'Ethernet bandwidth requirements
            'Please care for scanCONTROL_30xx_QuickReference.html to get further information
            'Example Configuration for 5kHz

            Dim iRetValue As Integer
            Dim auiResolutions(Max_RESOLUTIONS - 1) As UInteger
            Dim tmp As UInt32
            Console.WriteLine("Configure the sensor for high speed profile acquisition")
            Console.WriteLine("Set operating mode to high speed")
            CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp)
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp Or 1 << 30)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iRetValue)
            End If

            Console.WriteLine("Enable ROI1 free region")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_PRESET, 1 << 11)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_PRESET)", iRetValue)
            End If

            'Percentage X/Z of ROI
            Dim start_z As Double = 45.0
            Dim end_z As Double = 55.0
            Dim start_x As Double = 20.0
            Dim end_x As Double = 80.0

            Console.WriteLine("ROI1 Start Z (%): " & start_z)
            Console.WriteLine("ROI1 End Z (%): " & end_z)
            Console.WriteLine("ROI1 Start X (%): " & start_x)
            Console.WriteLine("ROI1 End X (%): " & end_x)

            ' X/Z raster for sensor matrix
            Dim col_start As UShort = (Math.Round(start_x / raster_x) * raster_x / 100 * 65536)
            Dim col_size As UShort = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
            Dim row_start As UShort = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
            Dim row_size As UShort = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            Console.WriteLine("Set ROI1_Position parameter")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_POSITION, (CUInt(col_start) << 16) + col_size)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_POSITION)", iRetValue)
            End If

            Console.WriteLine("Set ROI1_Distance parameter")
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_DISTANCE, (CUInt(row_start) << 16) + row_size)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_DISTANCE)", iRetValue)
            End If

            Console.WriteLine("Activate ROI1 free region" & Environment.NewLine)
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXTRA_PARAMETER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_EXTRA_PARAMETER)", iRetValue)
            End If

            ' Exposure Time / Idle Time in 
            Dim uiIdleTime As UInteger = 33
            Dim uiExposureTime As UInteger = 167

            Console.WriteLine("Set idle time to " & uiIdleTime)
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IDLETIME, (((uiIdleTime Mod 10) << 12) And &HF000) + ((uiIdleTime / 10) And &HFFF))
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_IDLETIME)", iRetValue)
            End If

            Console.WriteLine("Set exposure time to " & uiExposureTime)
            iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXPOSURE_TIME, (((uiExposureTime Mod 10) << 12) And &HF000) + ((uiExposureTime / 10 - 0.5) And &HFFF))        '(-0.5 wegen Rundungsfehler)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_SHUTTERTIME)", iRetValue)
            End If
            'Set resolution to 1/4
            Console.WriteLine("Get all possible resolutions")
            iRetValue = CLLTI.GetResolutions(hLLT, auiResolutions, auiResolutions.GetLength(0))
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetResolutions", iRetValue)
            End If
            uiResolution = auiResolutions(2)

            Console.WriteLine("Set resolution to " & uiResolution)
            iRetValue = CLLTI.SetResolution(hLLT, uiResolution)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetResolution", iRetValue)
            End If

            ' Profile configuration Partial Profile
            Console.WriteLine("Set Profile config to PARTIAL PROFILE")
            iRetValue = CLLTI.SetProfileConfig(hLLT, CLLTI.TProfileConfig.PARTIAL_PROFILE)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetProfileConfig", iRetValue)
            End If

            'Struct for a partial tansfer
            tPartialProfile.nStartPoint = 0                    'offset 0 -> start at the 21th point of the profile
            tPartialProfile.nStartPointData = 4                 ' data offset
            tPartialProfile.nPointCount = uiResolution       ' transmit  the full resolution
            tPartialProfile.nPointDataWidth = 4                 ' 4 bytes -> X und Z (each 2 bytes)

            Console.WriteLine("Set the partial profile struct")
            iRetValue = CLLTI.SetPartialProfile(hLLT, tPartialProfile)              'Vorteil struct
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetPartialProfile", iRetValue)
            End If

            Console.WriteLine("Set Packetsize to " & uiPacketSize)
            iRetValue = CLLTI.SetPacketSize(hLLT, uiPacketSize)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetPacketSize", iRetValue)
            End If
        End Sub


        ' Evalute received profiles via callback function
        Shared Sub GetProfiles_Callback()

            Dim iRetValue As Integer
            Dim adValueX(uiResolution) As Double
            Dim adValueZ(uiResolution) As Double

            ' Allocate the profile buffer to the maximal profile size times the profile count
            ReDim abyProfileBuffer(uiResolution * tPartialProfile.nPointDataWidth * uiNeededProfileCount)
            Dim abyTimestamp(16) As Byte

            ' Register the callback
            Console.WriteLine("Register the callback")
            ' Set the callback function
            Dim gch As GCHandle = GCHandle.Alloc(New CLLTI.ProfileReceiveMethod(AddressOf ProfileEvent))

            ' Register the callback
            iRetValue = CLLTI.RegisterCallback(hLLT, CLLTI.TCallbackType.STD_CALL, DirectCast(gch.Target, CLLTI.ProfileReceiveMethod), hLLT)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during RegisterCallback", iRetValue)
            End If


            ' Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
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
            If (uiProfileDataSize = uiResolution * tPartialProfile.nPointDataWidth) Then
                Console.WriteLine("Profile size is OK")
            Else
                Console.WriteLine("Profile size is wrong")
                Return
            End If

            Console.WriteLine(bProfileReceived & "profiles received")

            'Decode the timestamp from the first profile

            Buffer.BlockCopy(abyProfileBuffer, tPartialProfile.nPointDataWidth * uiResolution - 16, abyTimestamp, 0, 16)
            DisplayTimestamp(abyTimestamp)



            ' Stop continous profile transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If



        End Sub


        ' Callback function which copies the received data into the buffer and sets an event after the specified profiles
        Shared Sub ProfileEvent(ByVal data As IntPtr, uiSize As UInteger, uiUserData As UInteger)

            If (uiSize > 0) Then
                If (bProfileReceived < uiNeededProfileCount) Then
                    ' If the needed profile count not arrived: copy the new Profile in the buffer and increase the recived buffer count
                    uiProfileDataSize = uiSize
                    ' Kopieren des Unmanaged Datenpuffers (data) in die Anwendung
                    Marshal.Copy(data, abyProfileBuffer, bProfileReceived * uiSize, uiSize)
                    bProfileReceived += 1

                End If

                If (bProfileReceived >= uiNeededProfileCount) Then
                    ' If the needed profile count is arrived: set the event
                    hProfileEvent.Set()

                End If
            End If
        End Sub


        ' Display the timestamp
        Shared Sub DisplayTimestamp(abyTimestamp As Byte())

            Dim dShutterOpen As Double = 0.0
            Dim dShutterClose As Double = 0.0
            Dim uiProfileCount As UInteger = 0UI

            ' Decode the timestamp
            CLLTI.Timestamp2TimeAndCount(abyTimestamp, dShutterOpen, dShutterClose, uiProfileCount)
            uiProfilecountStart = uiProfileCount
            dShutteropenStart = dShutterOpen

            Buffer.BlockCopy(abyProfileBuffer, tPartialProfile.nPointDataWidth * uiResolution * uiNeededProfileCount - 16, abyTimestamp, 0, 16)
            CLLTI.Timestamp2TimeAndCount(abyTimestamp, dShutterOpen, dShutterClose, uiProfileCount)
            Console.WriteLine(uiProfileCount - uiProfilecountStart - (uiNeededProfileCount - 1) & " " & "Profiles lost")
            Console.WriteLine("Resulting profile frequency:" & ((uiNeededProfileCount - 1) / (dShutterOpen - dShutteropenStart)) & "Hz")

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