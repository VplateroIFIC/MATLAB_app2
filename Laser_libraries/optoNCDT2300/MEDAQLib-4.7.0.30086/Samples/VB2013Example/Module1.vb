Imports MicroEpsilon

Module Module1

	Private Function ShowError(ByVal location As String, ByRef sensor As MEDAQLib)
		Dim errText As String = ""
		ShowError = sensor.GetError(errText)
		Console.WriteLine(location + " returned error: " + errText)
		Console.WriteLine("Demo failed, press any key ...)")
		Console.ReadKey(True)
	End Function

	Private Function Open(ByRef sensor As MEDAQLib)
		Console.WriteLine("Open sensor ...")

		sensor.SetParameterInt("IP_EnableLogging", 1)
		If (sensor.OpenSensorRS232("COM9") <> ERR_CODE.ERR_NOERROR) Then 'IF2001/USB emulates a COM port
			Open = ShowError("OpenSensorRS232", sensor)
			Exit Function
		End If
		Open = ERR_CODE.ERR_NOERROR
	End Function

	Private Function GetParameters(ByRef sensor As MEDAQLib)
		Console.WriteLine("Get all parameters ...")

		If (sensor.ExecSCmd("Get_Info") <> ERR_CODE.ERR_NOERROR) Then
			GetParameters = ShowError("ExecSCmd (Get_Info)", sensor)
			Exit Function
		End If

		Dim sensorInfo As String = ""
		If (sensor.GetParameterString("SA_CompleteAnswer", sensorInfo) <> ERR_CODE.ERR_NOERROR) Then
			GetParameters = ShowError("GetParameters", sensor)
			Exit Function
		End If
		Console.WriteLine("Sensor info: {0}", sensorInfo)

		GetParameters = ERR_CODE.ERR_NOERROR
	End Function

	Private Function EnableDataOutput(ByRef sensor As MEDAQLib)
		Console.WriteLine("Enable data output ...")

		If (sensor.SetIntExecSCmd("Set_DataOutInterface", "SP_DataOutInterface", 1) <> ERR_CODE.ERR_NOERROR) Then	'RS422 output
			EnableDataOutput = ShowError("SetIntExecSCmd (Set_DataOutInterface)", sensor)
			Exit Function
		End If

		sensor.SetParameterInt("SP_OutputAdditionalShutterTime_RS422", 0)
		sensor.SetParameterInt("SP_OutputAdditionalCounter_RS422", 0)
		sensor.SetParameterInt("SP_OutputAdditionalTimestamp_RS422", 0)
		sensor.SetParameterInt("SP_OutputAdditionalIntensity_RS422", 0)
		sensor.SetParameterInt("SP_OutputAdditionalState_RS422", 0)
		sensor.SetParameterInt("SP_OutputAdditionalDistanceRaw_RS422", 0)
		If (sensor.ExecSCmd("Set_OutputAdditional_RS422") <> ERR_CODE.ERR_NOERROR) Then	'no additional output
			EnableDataOutput = ShowError("ExecSCmd (Set_OutputAdditional_RS422)", sensor)
			Exit Function
		End If

		sensor.SetParameterInt("SP_OutputVideoRaw_RS422", 0)
		If (sensor.ExecSCmd("Set_OutputVideo_RS422") <> ERR_CODE.ERR_NOERROR) Then	'no video signal output
			EnableDataOutput = ShowError("ExecSCmd (Set_OutputVideo_RS422)", sensor)
			Exit Function
		End If

		EnableDataOutput = ERR_CODE.ERR_NOERROR
	End Function

	Private Function TransferData(ByRef sensor As MEDAQLib)
		Console.WriteLine("Transfer data, press any key to stop ...")
		While (Console.KeyAvailable = False)
			System.Threading.Thread.Sleep(100) ' wait for new data
			Dim avail As Int32 = 0
			If (sensor.DataAvail(avail) <> ERR_CODE.ERR_NOERROR) Then
				TransferData = ShowError("DataAvail", sensor)
				Exit Function
			End If

			Dim rawData() As Int32
			Dim scaledData(avail - 1) As Double
			Dim read As Int32
			If (sensor.TransferData(rawData, scaledData, avail, read) <> ERR_CODE.ERR_NOERROR) Then	' warning BC42104 can be ignored, array will not be filled at TransferData
				TransferData = ShowError("TransferData", sensor)
				Exit Function
			End If
			Console.Write("{0}{1} Values: {2,4:F} ... {3,4:F}", vbCr, avail, scaledData(0), scaledData(avail - 1))
		End While

		Console.ReadKey(True)
		Console.WriteLine("")
		TransferData = ERR_CODE.ERR_NOERROR
	End Function

	Sub Main()
		Console.WriteLine("Start Demo...")
		Dim sensor As New MEDAQLib("ILD1420")
		If (Open(sensor) <> ERR_CODE.ERR_NOERROR) Then
			Return
		End If
		If (GetParameters(sensor) <> ERR_CODE.ERR_NOERROR) Then
			Return
		End If
		If (EnableDataOutput(sensor) <> ERR_CODE.ERR_NOERROR) Then
			Return
		End If
		If (TransferData(sensor) <> ERR_CODE.ERR_NOERROR) Then
			Return
		End If
		Console.WriteLine("Demo successfully finished, press any key ...")
		Console.ReadKey(True)
	End Sub

End Module
