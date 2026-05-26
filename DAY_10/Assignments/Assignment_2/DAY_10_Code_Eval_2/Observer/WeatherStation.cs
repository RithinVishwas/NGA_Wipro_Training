using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Observer
{
    public class WeatherStation : ISubject
    {
        private List<IObserver> observers =
            new List<IObserver>();

        private float temperature;

        public void RegisterObserver(IObserver observer)
        {
            observers.Add(observer);
        }

        public void RemoveObserver(IObserver observer)
        {
            observers.Remove(observer);
        }

        public void NotifyObservers()
        {
            foreach (var observer in observers)
            {
                observer.Update(temperature);
            }
        }

        public void SetTemperature(float temp)
        {
            temperature = temp;

            NotifyObservers();
        }
    }
}