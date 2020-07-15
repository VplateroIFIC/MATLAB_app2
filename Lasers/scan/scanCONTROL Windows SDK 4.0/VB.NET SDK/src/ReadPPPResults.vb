Imports System
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Threading
Imports System.Collections
Imports System.Collections.Generic
Imports System.Linq


Namespace VB

    Public Class VBscanCNONTROLSample

        ' Global variables
        Const MAX_INTERFACE_COUNT As Integer = 5
        Const Max_RESOLUTIONS As Integer = 6

        Public Shared uiResolution As UInteger = 0
        Public Shared hLLT As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType

        Public Shared abyProfileBuffer As Byte()

        Public Shared bProfileReceived As UInteger = 0
        Public Shared uiNeededProfileCount As UInteger = 10
        Public Shared uiProfileDataSize As UInteger = 0



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
            Dim uiIdleTime As UInteger = 900
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

                ' Setup callback
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Setup Callback function and event -----" & Environment.NewLine)

                    Console.WriteLine("Register the callback")
                    ' Set the callback function
                    Dim gch As GCHandle = GCHandle.Alloc(New CLLTI.ProfileReceiveMethod(AddressOf ProfileEvent))

                    ' Register the callback
                    iRetValue = CLLTI.RegisterCallback(hLLT, CLLTI.TCallbackType.STD_CALL, DirectCast(gch.Target, CLLTI.ProfileReceiveMethod), hLLT)

                    'gch.Free()
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during RegisterCallback", iRetValue)
                        bOK = False
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


        ' Evalute received profiles via callback function
        Shared Sub GetProfiles_Callback()

            Dim iRetValue As Integer
            Dim adValueX(uiResolution) As Double
            Dim adValueZ(uiResolution) As Double
            Dim m_vucModuleResult(64 * uiResolution) As UInteger
            Dim offset As Double = 65.0
            Dim scaling As Double = 0.001

            ' Allocate the profile buffer to the maximal profile size times the profile count
            ReDim abyProfileBuffer(uiResolution * 64 * uiNeededProfileCount)
            Dim abyTimestamp(16) As Byte


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
            If (uiProfileDataSize = uiResolution * 64) Then
                Console.WriteLine("Profile size is OK")
            Else
                Console.WriteLine("Profile size is wrong")
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

            'Display x And z values
            DisplayProfile(adValueX, adValueZ, uiResolution)

            ' Extract the 16-byte timestamp from the profile buffer into timestamp buffer and display it for each profile
            For iNeededProfile As Integer = 0 To uiNeededProfileCount - 1
                Buffer.BlockCopy(abyProfileBuffer, 64 * uiResolution * (iNeededProfile + 1) - 16, abyTimestamp, 0, 16)
                'DisplayTimestamp(abyTimestamp)
            Next

            Console.WriteLine("Extract post-processing results from the fourth stripe manually (uncompressed profile)")
            iRetValue = 0
            For i As Integer = 0 To uiResolution - 1
                m_vucModuleResult(i) = (CUInt(abyProfileBuffer(i * 64 + 52)) << 24) + (CUInt(abyProfileBuffer(i * 64 + 53)) << 16) + (CUInt(abyProfileBuffer(i * 64 + 54)) << 8) + abyProfileBuffer(i * 64 + 55)
                iRetValue += 1
            Next

            Console.WriteLine("Get appended results" & Environment.NewLine)

            iRetValue = GetAppendedResults(m_vucModuleResult, iRetValue, False, offset, scaling)

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

        Shared Function GetAppendedResults(ByRef vucModuleResult() As UInteger, nModuleResultSize As Integer, littleEndian As Boolean, offset As Double, scaling As Double) As Integer

            Dim idx As Integer = 0
            Dim length As UInteger = 0
            Dim dataArr(15) As UInteger
            Dim list As New List(Of List(Of UInteger))
            Dim i As Integer = 0
            Dim j As Integer = 0

            For s As Integer = 0 To nModuleResultSize
                list.Add(New List(Of UInteger))
            Next


            'Step 1: collect Data into vector of arrays
            For i = 0 To nModuleResultSize - 1

                If (Not littleEndian) Then

                    If (((vucModuleResult(i) >> 24) And &HFF) = 131) Then

                        length = vucModuleResult(i) And &HFF

                        For j = i + 2 To (i + length) - 1


                            'Get components of measurement value
                            dataArr(0) = ((vucModuleResult(j) And &HFC000000) >> 26)        'type
                            dataArr(1) = ((vucModuleResult(j) And &H2000000) >> 25)         'description via value
                            dataArr(2) = ((vucModuleResult(j) And &H1000000) >> 24)         'description graphical
                            dataArr(3) = ((vucModuleResult(j) And &H800000) >> 23)          'length_16_32
                            dataArr(4) = ((vucModuleResult(j) And &H400000) >> 22)          'upper_lower
                            dataArr(5) = ((vucModuleResult(j) And &H200000) >> 21)          'mv_valid
                            dataArr(6) = ((vucModuleResult(j) And &H100000) >> 20)          'mv_name
                            dataArr(7) = ((vucModuleResult(j) And &H80000) >> 19)           'mv_output
                            If (Convert.ToBoolean(dataArr(1))) Then
                                'description via value
                                dataArr(8) = ((vucModuleResult(j) And &H7FF80) >> 7)       'mv_data
                            Else
                                'description via pointer
                                dataArr(8) = vucModuleResult((vucModuleResult(j) And &H7FF80) >> 7)        'mv_data
                                'Console.WriteLine("Zeile: " & ((vucModuleResult(j) And &H7FF80) >> 7))
                            End If

                            dataArr(9) = ((vucModuleResult(j) And &H40) >> 6)               'mask_active
                            dataArr(10) = ((vucModuleResult(j) And &H20) >> 5)              'mv_not_show_num
                            dataArr(11) = ((vucModuleResult(j) And &H10) >> 4)              'mv_OK_NOK_available
                            dataArr(12) = 0 'Reservation for OK/NOK
                            dataArr(13) = (vucModuleResult(j) And &HF)                      'mv_len_description
                            If (dataArr(13) = 2) Then
                                'mv_len_description
                                j += 1
                                dataArr(14) = vucModuleResult(j) 'mv_mask
                            End If

                            'append to datalist
                            list(j).AddRange(dataArr)

                            'increase number of detected values
                            idx += 1

                        Next
                        Exit For
                    Else
                        'If header is not 131 add length of result block to i to skip results of current module
                        'i += CInt(vucModuleResult(i) And &HFF) - 1
                    End If
                Else
                    Console.WriteLine("Module results in little endian order - conversion example for big endian only!")
                End If
            Next


            'Step 2: Add OK/NOK to array if available
            Dim oknok_counter As Integer = 0

            For i = i + 2 To (i + length) - 1
                Try
                    If (Convert.ToBoolean(list(i)(11))) Then
                        'OK/NOK available
                        'Look for OK/NOK vector
                        If (list((i + length) - 1)(0) = 30) Then
                            'Type OK/NOK
                            list(i)(12) = CUInt(list((i + length) - 1)(8) And (1 << oknok_counter)) >> oknok_counter
                            oknok_counter += 1
                        End If
                    End If
                Catch ex As ArgumentOutOfRangeException
                    '''''''''''''''''''
                End Try
            Next


            For j = ((j - (idx * 2)) + 2) To ((j + length) - (idx)) - 1


                Try
                    'Assign Array values to variables
                    Dim type As UInteger = list(j)(0)
                    Dim description_via_value As Boolean = Convert.ToBoolean(list(j)(1))
                    Dim description_graphical As Boolean = Convert.ToBoolean(list(j)(2))
                    Dim length_16_32 As Boolean = Convert.ToBoolean(list(j)(3))
                    Dim upper_lower As Boolean = Convert.ToBoolean(list(j)(4))
                    Dim mv_valid As Boolean = Convert.ToBoolean(list(j)(5))
                    Dim mv_name As Boolean = Convert.ToBoolean(list(j)(6))
                    Dim mv_output As Boolean = Convert.ToBoolean(list(j)(7))
                    Dim mv_data As UInteger = list(j)(8)
                    Dim mask_active As Boolean = Convert.ToBoolean(list(j)(9))
                    Dim mv_not_show_num As Boolean = Convert.ToBoolean(list(j)(10))
                    Dim mv_OK_NOK_available As Boolean = Convert.ToBoolean(list(j)(11))
                    Dim mv_OK_NOK As Boolean = Convert.ToBoolean(list(j)(12))
                    Dim mv_len_description As UInteger = list(j)(13)
                    Dim mv_mask As UInteger = list(j)(14)

                    'Convert measurement value according to type:
                    Select Case (type)
                        Case 1
                            Console.Write("X: ")
                            Dim x As Double = 0
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                x = CInt((mv_data - 32768) * scaling)
                            Else
                                If (upper_lower) Then
                                    'x in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    x = ((mv_data And &HFFFF) - 32768) * scaling
                                Else
                                    ' x in upper 16 bit
                                    Console.Write("(16bit upper): ")
                                    x = (((mv_data And &HFFFF0000) >> 16) - 32768) * scaling
                                End If

                            End If
                            Console.Write(x)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 2
                            Console.Write("Z: ")
                            Dim z As Double = 0.0
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                z = CInt((mv_data - 32768) * scaling + offset)
                            Else
                                If (upper_lower) Then
                                    'z in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    z = ((mv_data And &HFFFF) - 32768) * scaling + offset
                                Else
                                    ' z in upper 16 bit
                                    Console.Write("(16bit upper): ")
                                    z = (((mv_data And &HFFFF0000) >> 16) - 32768) * scaling + offset
                                End If

                            End If
                            Console.Write(z)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 3
                            Console.Write("Binary: ")
                            Dim bin As UInteger
                            If (length_16_32) Then
                                '32 bit length
                                If (mask_active) Then
                                    bin = mv_data And mv_mask
                                Else
                                    bin = mv_data
                                End If
                            Else
                                ' 16bit length
                                If (upper_lower) Then
                                    ' bin in lower 16 bit
                                    bin = mv_data And &HFFFF
                                Else
                                    'bin in upper 16 bit
                                    bin = (mv_data And &HFFFF0000) >> 16
                                End If

                            End If
                            Console.Write(bin)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 4
                            Console.Write("Integer: ")
                            Dim intvalue As UInteger = 0
                            If (mask_active) Then
                                Console.Write("(mask): ")
                                intvalue = (mv_data And mv_mask)
                                If (Not Convert.ToBoolean(mv_mask And &HFFFF)) Then
                                    'Temperature is in upper 16 Bit
                                    intvalue = intvalue >> 16
                                End If
                            Else
                                If (length_16_32) Then
                                    '32 bit length
                                    Console.Write("(32bit): ")
                                    intvalue = mv_data
                                Else
                                    ' 16bit length
                                    If (upper_lower) Then
                                        ' integer in lower 16 bit
                                        Console.Write("(16bit lower): ")
                                        intvalue = mv_data And &HFFFF
                                    Else
                                        'integer in upper 16 bit
                                        Console.Write("(16bit upper): ")
                                        intvalue = (mv_data And &HFFFF0000) >> 16
                                    End If
                                End If
                            End If
                            Console.Write(intvalue)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 5
                            Console.Write("Distance: ")
                            Dim distance As Double = 0
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                distance = (mv_data - 32768) * scaling
                            Else
                                If (upper_lower) Then
                                    'distance in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    distance = ((mv_data And &HFFFF) - 32768) * scaling
                                Else
                                    ' distance in upper 16 bit
                                    Console.Write("(16bit upper): ")
                                    distance = (((mv_data And &HFFFF0000) >> 16) - 32768) * scaling
                                End If

                            End If
                            Console.Write(distance)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 6
                            Console.Write("Angle: ")
                            Dim angle As Double = 0
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                angle = CInt((mv_data - 32768) * 0.01)
                            Else
                                If (upper_lower) Then
                                    'angle in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    angle = ((mv_data And &HFFFF) - 32768) * 0.01
                                Else
                                    ' angle in upper 16 bit
                                    Console.Write("(16bit upper): ")
                                    angle = ((mv_data And &HFFFF0000) >> 16) * 0.01
                                End If

                            End If
                            Console.Write(angle)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 7
                            Console.Write("Area: ")
                            Dim area As Double = 0
                            area = mv_data * scaling * scaling
                            Console.Write(area)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 8
                            Console.Write("Point: ")
                            Dim x As Double
                            Dim z As Double
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                Dim ptr_x As UInteger = (mv_mask And &HFFF00000) >> 20
                                x = (vucModuleResult(ptr_x) - 32768) * scaling
                                Dim ptr_z As UInteger = (mv_mask And &HFFF0) >> 8
                                z = (vucModuleResult(ptr_z) - 32768) * scaling + offset

                            Else
                                ' 16 bit length
                                Console.Write("(16bit): ")
                                x = (((mv_data And &HFFFF0000) >> 16) - 32768) * scaling
                                z = ((mv_data And &HFFFF) - 32768) * scaling + offset
                                Console.Write(x & " , " & z)

                                If (mv_OK_NOK_available) Then
                                    Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                                End If

                            End If
                            Console.Write(Environment.NewLine)
                        Case 9
                            Console.Write("Sigma: ")
                            Dim sigma As Double = 0
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                sigma = mv_data * scaling
                            Else
                                If (upper_lower) Then
                                    'sigma in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    sigma = (mv_data And &HFFFF) * scaling
                                Else
                                    ' sigma in upper 16 bit
                                    Console.Write("(16bit upper): ")
                                    sigma = ((mv_data And &HFFFF0000) >> 16) * scaling
                                End If

                            End If
                            Console.Write(sigma)
                            If (mv_OK_NOK_available) Then
                                Console.Write(" (NOK/OK: " & mv_OK_NOK & ")")
                            End If
                            Console.Write(Environment.NewLine)
                        Case 10
                            Console.Write("Text: ")
                            Dim text(4) As Char
                            If (length_16_32) Then
                                '32 bit length
                                Console.Write("(32bit): ")
                                text(0) = Convert.ToChar((mv_data >> 24) And &HFF)
                                text(1) = Convert.ToChar((mv_data >> 16) And &HFF)
                                text(2) = Convert.ToChar((mv_data >> 8) And &HFF)
                                text(3) = Convert.ToChar(mv_data And &HFF)
                            Else
                                If (upper_lower) Then
                                    'sigma in lower 16 bit
                                    Console.Write("(16bit lower): ")
                                    text(0) = Convert.ToChar((mv_data >> 8) And &HFF)
                                    text(1) = Convert.ToChar(mv_data And &HFF)
                                Else
                                    Console.Write("(16bit upper): ")
                                    text(0) = Convert.ToChar((mv_data >> 24) And &HFF)
                                    text(1) = Convert.ToChar((mv_data >> 16) And &HFF)
                                End If
                            End If
                            For Each chr As Char In text
                                Console.Write(chr)

                            Next
                            Console.Write(Environment.NewLine)

                        Case 30
                            Console.WriteLine("OK/NOK: ")
                            If (length_16_32) Then
                                Console.Write("(32bit): ")
                                Console.Write((mv_data And &HFF) & "\n")
                            Else
                                If (upper_lower) Then
                                    Console.Write("(16bit lower): ")
                                    Console.Write((mv_data And &HFFFF) & "\n")
                                Else
                                    Console.Write("(16bit upper): ")
                                    Console.Write((mv_data And &HFFFF0000) & "\n")
                                End If
                            End If
                        Case Else
                            Console.WriteLine("Unknown: (" & type & ") " & Environment.NewLine)



                    End Select

                Catch ex As ArgumentOutOfRangeException
                    '''''''''''
                End Try
            Next

            Return idx
        End Function

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