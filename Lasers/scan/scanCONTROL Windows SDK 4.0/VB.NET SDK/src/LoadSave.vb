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
        Public Shared sbAviFilename As StringBuilder = New StringBuilder("LoadSaveSample.avi")

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
                iRetValue = CLLTI.SetDeviceInterface(hLLT, auiInterfaces(1), 0)
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
                Console.WriteLine(Environment.NewLine & "----- Load and Save parameters from/to scanCONTROL  -----" & Environment.NewLine)
                LoadSaveParametersfromscanCONTROL()
            End If


            If (bOK) Then
                Console.WriteLine(Environment.NewLine & "----- Import and Export configuration of scanCONTROL  -----" & Environment.NewLine)
                'ImportExportConfigurationToFile()
            End If

            If (bOK) Then
                Console.WriteLine(Environment.NewLine & "----- Save profiles from scanCONTROL  -----" & Environment.NewLine)
                bOK = SaveProfiles()
            End If

            If (bOK) Then
                Console.WriteLine(Environment.NewLine & "----- Load profiles from saved avi  -----" & Environment.NewLine)
                LoadProfiles()
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

        Shared Function LoadSaveParametersfromscanCONTROL()

            Dim uiCurrentUserMode As UInteger = 0
            Dim uiUserModeCount As UInteger = 0
            Dim uiWorkingUserMode As UInteger = 7
            Dim iRetValue As Integer

            'Get current UserMode
            Console.WriteLine("GetActualUserMode")
            iRetValue = CLLTI.GetActualUserMode(hLLT, uiCurrentUserMode, uiUserModeCount)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during getting UM", iRetValue)
                Return False
            Else
                Console.WriteLine(" - Current UM : " & uiCurrentUserMode & " - Available UMs: " & uiUserModeCount)
            End If

            'Write settings to usermode
            Console.WriteLine("Write settings to Usermode 7")
            iRetValue = CLLTI.ReadWriteUserModes(hLLT, 1, uiWorkingUserMode)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during writing UM 7", iRetValue)
                Return False
            End If
            System.Threading.Thread.Sleep(100)

            'Get current UserMode
            Console.WriteLine("GetActualUserMode")
            iRetValue = CLLTI.GetActualUserMode(hLLT, uiCurrentUserMode, uiUserModeCount)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during getting UM", iRetValue)
                Return False
            Else
                Console.WriteLine(" - Current UM : " & uiCurrentUserMode & " - Available UMs: " & uiUserModeCount)
            End If

            'Load settings from usermode
            Console.WriteLine("Load Usermode 7")
            iRetValue = CLLTI.ReadWriteUserModes(hLLT, 0, uiWorkingUserMode)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during loading UM 7", iRetValue)
                Return False
            End If

            Return True
        End Function

        Shared Function ImportExportConfigurationToFile()

            Dim iRetValue As Integer
            Dim sbExportedConfig As StringBuilder = New StringBuilder("lltConfigExport.txt")
            Dim sbImportConfig As StringBuilder = New StringBuilder("lltConfigImportSample.sc1")

            'Export the complete configuration to a file
            Console.WriteLine("Export LLT Config to " & sbExportedConfig.ToString)
            iRetValue = CLLTI.ExportLLTConfig(hLLT, sbExportedConfig)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during exporting Config", iRetValue)
                Return False
            End If

            'Import the complete configuration from the sbExportedConfig file
            Console.WriteLine("Import LLT Config from " & sbExportedConfig.ToString)
            iRetValue = CLLTI.ImportLLTConfig(hLLT, sbExportedConfig, True)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during importing Config", iRetValue)
                Return False
            End If

            'Import configuration from .sc1 file
            Console.WriteLine("Import LLT Config from " & sbImportConfig.ToString)
            'file has to be located in the same directory as the build path
            iRetValue = CLLTI.ImportLLTConfig(hLLT, sbImportConfig, True)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during importing Config from sc1 file", iRetValue)
                Return False
            End If

            Return True
        End Function

        Shared Function SaveProfiles()

            Dim iRetValue As Integer


            'Start the profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return False
            End If

            'Start saving profiles to avi files
            Console.WriteLine("Enable the save process")
            iRetValue = CLLTI.SaveProfiles(hLLT, sbAviFilename, CLLTI.TFileType.AVI)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Saving", iRetValue)
                Return False
            End If

            ' Sleep for the time you want to save
            System.Threading.Thread.Sleep(2000)

            'Stop saving profiles to avi file
            Console.WriteLine("Disable the save process")
            iRetValue = CLLTI.SaveProfiles(hLLT, Nothing, CLLTI.TFileType.AVI)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Saving", iRetValue)
                Return False
            End If

            ' Disable the measurement
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return False
            End If
            Return True

        End Function

        ' Load a saved profile sequence from a .avi file
        Shared Function LoadProfiles()

            Dim iRetValue As Integer

            'Create struct instances for parameters
            Dim tPartialProfile As CLLTI.TPartialProfile = New CLLTI.TPartialProfile
            Dim tProfileConfig As CLLTI.TProfileConfig = New CLLTI.TProfileConfig
            Dim tScannerType As CLLTI.TScannerType = New CLLTI.TScannerType

            Dim uiRearrangement As UInteger = 0
            Dim uiProfileCount As UInteger = 0
            Dim uiLostProfiles As UInteger = 0

            'Enable the load process
            Console.WriteLine("Enable the load process")
            iRetValue = CLLTI.LoadProfiles(hLLT, sbAviFilename, tPartialProfile, tProfileConfig, tScannerType, uiRearrangement)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during Loading", iRetValue)
                Return False
            End If

            Console.WriteLine("Loaded data: - PartialProfile:" & tPartialProfile.ToString & "- tScannerType: " & tscanCONTROLType.ToString & " - uiRearrangement: " & uiRearrangement)

            'Allocate buffer for loading profiles into
            Dim abyProfileBuffer(tPartialProfile.nPointCount * 64 - 1) As Byte

            iRetValue = tPartialProfile.nPointCount * 64

            'Reading of the saved profiles
            While (iRetValue = tPartialProfile.nPointCount * 64)

                iRetValue = CLLTI.GetActualProfile(hLLT, abyProfileBuffer, abyProfileBuffer.GetLength(0), CLLTI.TProfileConfig.PROFILE, uiLostProfiles)
                uiProfileCount = uiProfileCount + 1
                Console.Write("Read Profil: " & uiProfileCount & Environment.NewLine)

            End While

            Console.WriteLine(uiProfileCount & " profiles read from the saved file")

            Return True

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