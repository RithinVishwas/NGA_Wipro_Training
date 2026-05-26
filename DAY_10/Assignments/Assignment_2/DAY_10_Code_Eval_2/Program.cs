using System;
using DAY_10_Code_Eval_2.Singleton;
using DAY_10_Code_Eval_2.Factory;
using DAY_10_Code_Eval_2.Observer;

namespace DAY_10_Code_Eval_2
{
    class Program
    {
        static void Main(string[] args)
        {
            // ================= SINGLETON =================

            Console.WriteLine("===== SINGLETON PATTERN =====");

            Logger logger1 = Logger.GetInstance();

            Logger logger2 = Logger.GetInstance();

            logger1.Log("Application Started");

            Console.WriteLine(
                $"Same Instance: {ReferenceEquals(logger1, logger2)}");

            Console.WriteLine();

            // ================= FACTORY =================

            Console.WriteLine("===== FACTORY PATTERN =====");

            DocumentFactory factory =
                new DocumentFactory();

            IDocument pdf =
                factory.CreateDocument("PDF");

            pdf.Open();

            IDocument word =
                factory.CreateDocument("WORD");

            word.Open();

            Console.WriteLine();

            // ================= OBSERVER =================

            Console.WriteLine("===== OBSERVER PATTERN =====");

            WeatherStation station =
                new WeatherStation();

            WeatherDisplay mobileDisplay =
                new WeatherDisplay("Mobile Display");

            WeatherDisplay tvDisplay =
                new WeatherDisplay("TV Display");

            station.RegisterObserver(mobileDisplay);

            station.RegisterObserver(tvDisplay);

            station.SetTemperature(32.5f);

            Console.ReadLine();
        }
    }
}