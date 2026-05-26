using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Observer
{
    public class WeatherDisplay : IObserver
    {
        private string displayName;

        public WeatherDisplay(string name)
        {
            displayName = name;
        }

        public void Update(float temperature)
        {
            Console.WriteLine(
                $"{displayName} received update: Temperature = {temperature}°C");
        }
    }
}