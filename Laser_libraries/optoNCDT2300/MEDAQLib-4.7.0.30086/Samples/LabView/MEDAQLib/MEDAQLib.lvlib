<?xml version='1.0' encoding='UTF-8'?>
<Library LVVersion="8608001">
	<Property Name="Instrument Driver" Type="Str">True</Property>
	<Property Name="NI.Lib.DefaultMenu" Type="Str">dir.mnu</Property>
	<Property Name="NI.Lib.Description" Type="Str">LabVIEW Plug and Play instrument driver for Micro-Epsilon sensors basing upon Micro-Epsilon Data Acquisition Library (MEDAQLib).

MEDAQLib is a software library for easy data acquisition and communication with
digital Micro-Epsilon sensors. The library is independent from any communication
protocol or hardware interface, i.e.  all sensors or controllers are accessed from
your program in the same way independent whether via TCP/IP or USB or serial
communication.</Property>
	<Property Name="NI.Lib.Icon" Type="Bin">#'#!!1!!!!)!"1!&amp;!!!-!%!!!@````]!!!!"!!%!!!)O!!!*Q(C=\&gt;4"E&gt;J!%)8BNSY@@#5$&amp;^=^&gt;AKE1!K&gt;!N=^EE+H1!KE]"1#+:##`'NI5?S[SFTMMFWVEE?'.T-^(S/NJ(&amp;]E\ZK@H+]0DOG[8;:JP7S@,`V4)`^;`[B4?MZ4?_SH`I@ZP@9&gt;&gt;A[9_W`8_]F8N`Z\F7YTPLF-8`W@`&lt;`V`V0$M;]02XUBQ`J:5BJJB5N;4&amp;_X7RSEZP=Z#9X?:%8?:%8?:%8?:)H?:)H?:)H?:!(?:!(?:!(_4D*23ZSE&lt;-L:H'TE#FK#JD"5'1ORG-]RG-]@*8R')`R')`R-%4'9TT'9TT'QT1:D`%9D`%9$[7'R/-ERW-]F&amp;@B+4S&amp;J`!5(J:5Y3E!R7*&amp;Y;))$"7&gt;R9@#5XA+$R^6?!J0Y3E]B9&gt;O&amp;:\#5XA+4_&amp;BSNC6'JLF*-&gt;$'37?R*.Y%E`CI&lt;134_**0)EH]&lt;#=%E`C32$*AEFR#%IG*1/3,YEH]@#@%E`C34S**`(1.?Z1DJV:.-N*DC@Q"*\!%XA#$S55?!*0Y!E]A9?S#DS"*`!%HM$$5AI]A3@Q"*"A5::85#S9'!Q+AM$$P`'UR,B,.31RTP\4P$WI[A&gt;1`7#J(RDVA[#_Q?I&lt;J\YB[IV7&lt;["[9^1`70V$V%$VQOK#[I'[=LX1TL14\5A\U0;U(7V,WSR4@`0![`7KS_7C]`GMU_GEY`'IQ_'A`8[PX7[H\8;LT7:T@VN^Z\Q&gt;,_N\[9X0@[0&gt;XEP`QLN28T1`P/&lt;:IR^=-U"^!!!!!!</Property>
	<Property Name="NI.Lib.Version" Type="Str">1.0.0.0</Property>
	<Item Name="Public" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">1</Property>
		<Item Name="Action-Status" Type="Folder">
			<Item Name="Action-Status.mnu" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/Action-Status.mnu"/>
			<Item Name="DataAvail.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/DataAvail.vi"/>
			<Item Name="GetError.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/GetError.vi"/>
			<Item Name="GetParameterDouble.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/GetParameterDouble.vi"/>
			<Item Name="GetParameterDWORD_PTR.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/GetParameterDWORD_PTR.vi"/>
			<Item Name="GetParameterInt.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/GetParameterInt.vi"/>
			<Item Name="GetParameterString.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Action-Status/GetParameterString.vi"/>
		</Item>
		<Item Name="Configure" Type="Folder">
			<Item Name="Configure.mnu" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/Configure.mnu"/>
			<Item Name="SensorCommand.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SensorCommand.vi"/>
			<Item Name="SetParameterDouble.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SetParameterDouble.vi"/>
			<Item Name="SetParameterDWORD_PTR.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SetParameterDWORD_PTR.vi"/>
			<Item Name="SetParameterInt.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SetParameterInt.vi"/>
			<Item Name="SetParameterString.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SetParameterString.vi"/>
			<Item Name="SetParameterBinary.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Configure/SetParameterBinary.vi"/>
		</Item>
		<Item Name="Data" Type="Folder">
			<Item Name="Data.mnu" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Data/Data.mnu"/>
			<Item Name="Poll.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Data/Poll.vi"/>
			<Item Name="TransferData.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Data/TransferData.vi"/>
			<Item Name="TransferDataTS.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/TransferDataTS.vi"/>
		</Item>
		<Item Name="Utility" Type="Folder">
			<Item Name="Utility.mnu" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/Utility.mnu"/>
			<Item Name="ClearAllParameters.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ClearAllParameters.vi"/>
			<Item Name="CloseSensor.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/CloseSensor.vi"/>
			<Item Name="CreateSensorInstance.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/CreateSensorInstance.vi"/>
			<Item Name="EnableLogging.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/EnableLogging.vi"/>
			<Item Name="ErrorHandler.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ErrorHandler.vi"/>
			<Item Name="ExecSCmd.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ExecSCmd.vi"/>
			<Item Name="ExecSCmdGetDouble.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ExecSCmdGetDouble.vi"/>
			<Item Name="ExecSCmdGetInt.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ExecSCmdGetInt.vi"/>
			<Item Name="ExecSCmdGetString.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ExecSCmdGetString.vi"/>
			<Item Name="GetDLLPath.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/GetDLLPath.vi"/>
			<Item Name="OpenSensor.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/OpenSensor.vi"/>
			<Item Name="OpenSensorIF2004.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/OpenSensorIF2004.vi"/>
			<Item Name="OpenSensorIF2008.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/OpenSensorIF2008.vi"/>
			<Item Name="OpenSensorTCPIP.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/OpenSensorTCPIP.vi"/>
			<Item Name="OpenSensorRS232.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/OpenSensorRS232.vi"/>
			<Item Name="ReleaseSensorInstance.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/ReleaseSensorInstance.vi"/>
			<Item Name="SetDoubleExecSCmd.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/SetDoubleExecSCmd.vi"/>
			<Item Name="SetIntExecSCmd.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/SetIntExecSCmd.vi"/>
			<Item Name="SetStringExecSCmd.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/SetStringExecSCmd.vi"/>
			<Item Name="CreateSensorInstByName.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Utility/CreateSensorInstByName.vi"/>
		</Item>
		<Item Name="Example" Type="Folder">
			<Item Name="Interface-Ethernet.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Example/Interface-Ethernet.vi"/>
			<Item Name="Interface-IF2004_USB.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Example/Interface-IF2004_USB.vi"/>
			<Item Name="Interface-RS232.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/Example/Interface-RS232.vi"/>
		</Item>
		<Item Name="dir.mnu" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/Public/dir.mnu"/>
		<Item Name="VI Tree.vi" Type="VI" URL="/&lt;instrlib&gt;/MEDAQLib/Public/VI Tree.vi"/>
	</Item>
	<Item Name="Private" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
	</Item>
	<Item Name="Release" Type="Folder"/>
	<Item Name="MEDAQLib Readme.html" Type="Document" URL="/&lt;instrlib&gt;/MEDAQLib/MEDAQLib Readme.html"/>
</Library>
