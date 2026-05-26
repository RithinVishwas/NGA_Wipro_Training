using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Observer
{
    public interface IObserver
    {
        void Update(float temperature);
    }
}