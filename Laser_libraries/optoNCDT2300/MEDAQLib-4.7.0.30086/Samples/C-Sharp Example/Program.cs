using System;
using MicroEpsilon; // MEDAQLib

namespace C_Sharp_Example
{
	class Program
	{
		static ERR_CODE Error(string location, ref MEDAQLib sensor)
		{
			string errText = "";
			ERR_CODE err = sensor.GetError(ref errText);
			Console.WriteLine(location + " returned error: " + errText);
			Console.WriteLine("Demo failed, press any key ...)");
			Console.ReadKey(true);
			return err;
		}

		static ERR_CODE Open(ref MEDAQLib sensor)
		{
			Console.WriteLine("Open sensor ...");

			sensor.SetParameterInt("IP_EnableLogging", 1);
			if (sensor.OpenSensorTCPIP("169.254.168.150") != ERR_CODE.ERR_NOERROR)
				return Error("OpenSensorTCPIP", ref sensor);

			return ERR_CODE.ERR_NOERROR;
		}

		static ERR_CODE GetParameters(ref MEDAQLib sensor)
		{
			Console.WriteLine("Get all parameters ...");

			if (sensor.SetIntExecSCmd("Get_AllParameters", "SP_Additional", 1) != ERR_CODE.ERR_NOERROR)
				return Error("SetIntExecSCmd (Get_AllParameters)", ref sensor);

			string serial = "";
			if (sensor.GetParameterString("SA_SerialNumber", ref serial) != ERR_CODE.ERR_NOERROR)
				return Error("GetParameterString (SA_SerialNumber)", ref sensor);
			Console.WriteLine("SA_SerialNumber: {0}", serial);

			double range = 0;
			if (sensor.GetParameterDouble("SA_Range", ref range) != ERR_CODE.ERR_NOERROR)
				return Error("GetParameterDouble (SA_Range)", ref sensor);
			Console.WriteLine("Sensor range: {0} mm", range);

			return ERR_CODE.ERR_NOERROR;
		}

		static ERR_CODE GetVideo(ref MEDAQLib sensor)
		{
			Console.WriteLine("Get video signal ...");

			int oldMeasMode = 0;
			if (sensor.ExecSCmdGetInt("Get_MeasureMode", "SA_MeasureMode", ref oldMeasMode) != ERR_CODE.ERR_NOERROR)
				return Error("ExecSCmdGetInt (Get_MeasureMode)", ref sensor);

			if (sensor.SetIntExecSCmd("Set_MeasureMode", "SP_MeasureMode", 3/*Video*/) != ERR_CODE.ERR_NOERROR)
				return Error("SetIntExecSCmd (Set_MeasureMode)", ref sensor);

			sensor.SetParameterInt("SP_OutputVideoRaw_ETH", 0);
			sensor.SetParameterInt("SP_OutputVideoCorr_ETH", 1);
			if (sensor.ExecSCmd("Set_OutputVideo_ETH") != ERR_CODE.ERR_NOERROR)
				return Error("ExecSCmd (Set_OutputVideo_ETH)", ref sensor);

			if (sensor.ExecSCmd("Get_Video") != ERR_CODE.ERR_NOERROR)
				return Error("ExecSCmd (Get_Video)", ref sensor);

			byte[] bArray = null;
			if (sensor.GetParameterBinary("SA_VideoCorr", ref bArray) != ERR_CODE.ERR_NOERROR)
				return Error("GetParameterBinary (SA_VideoCorr)", ref sensor);

			short[] sArray = new short[bArray.Length / 2];
			Buffer.BlockCopy(bArray, 0, sArray, 0, bArray.Length);

			for (int i = 0; i < sArray.Length; i++)
			{
				Console.Write(sArray[i]);
				Console.Write(" ");
			}
			Console.WriteLine("");

			if (sensor.SetIntExecSCmd("Set_MeasureMode", "SP_MeasureMode", oldMeasMode) != ERR_CODE.ERR_NOERROR)
				return Error("SetIntExecSCmd (Set_MeasureMode)", ref sensor);

			return ERR_CODE.ERR_NOERROR;
		}

		static ERR_CODE TransferData(ref MEDAQLib sensor)
		{
			Console.WriteLine("Transfer data ...");

			System.Threading.Thread.Sleep(100); // Wait for data

			int avail = 0;
			if (sensor.DataAvail(ref avail) != ERR_CODE.ERR_NOERROR)
				return Error("DataAvail", ref sensor);

			int show = Math.Min(avail, 5);
			Console.WriteLine("{0} Values available, printing first {1} ones", avail, show);

			int[] rawData = new int[avail];
			double[] scaledData = new double[avail];
			int read = 0;
			if (sensor.TransferData(rawData, scaledData, avail, ref read) != ERR_CODE.ERR_NOERROR)
				return Error("TransferData", ref sensor);
			System.Diagnostics.Debug.Assert(avail == read);

			for (int i = 0; i < show; i++)
				Console.WriteLine("Value {0,2} Raw: {1} / Scaled: {2,4:F}", i + 1, rawData[i], scaledData[i]);
			Console.WriteLine("");

			return ERR_CODE.ERR_NOERROR;
		}

		static ERR_CODE PollData(ref MEDAQLib sensor)
		{
			Console.WriteLine("Poll data, press any key to stop ...");

			while (!Console.KeyAvailable)
			{
				System.Threading.Thread.Sleep(100); // Wait for new data
				int[] rawData = { 0 };
				double[] scaledData = {0};
				if (sensor.Poll(rawData, scaledData, 1) != ERR_CODE.ERR_NOERROR)
					return Error("Poll", ref sensor);
				Console.Write("\rRaw: {0} / Scaled: {1,4:F}", rawData[0], scaledData[0]);
			}

			Console.ReadKey(true);
			Console.WriteLine("");

			return ERR_CODE.ERR_NOERROR;
		}

		static void Main(string[] args)
		{
			Console.WriteLine("Start Demo...");
			MEDAQLib sensor = new MEDAQLib("ILD2300");
			if (Open(ref sensor) != ERR_CODE.ERR_NOERROR)
				return;
			if (GetParameters(ref sensor) != ERR_CODE.ERR_NOERROR)
				return;
			if (GetVideo(ref sensor) != ERR_CODE.ERR_NOERROR)
				return;
			if (TransferData(ref sensor) != ERR_CODE.ERR_NOERROR)
				return;
			if (PollData(ref sensor) != ERR_CODE.ERR_NOERROR)
				return;
			Console.WriteLine("Demo successfully finished, press any key ...");
			Console.ReadKey(true);
		}
	}
}
