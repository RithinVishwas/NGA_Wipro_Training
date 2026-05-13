using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_6_Assignment_CSharp_Order_Event_System.Services
{
    using System;

    public class LoggerService
    {
        public void LogOrder(Order order)
        {
            Console.WriteLine("Order logged successfully");
        }
    }
}
