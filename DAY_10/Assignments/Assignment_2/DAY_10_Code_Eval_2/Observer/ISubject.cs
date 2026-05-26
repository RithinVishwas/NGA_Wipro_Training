using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Observer
{
    public interface ISubject
    {
        void RegisterObserver(IObserver observer);

        void RemoveObserver(IObserver observer);

        void NotifyObservers();
    }
}