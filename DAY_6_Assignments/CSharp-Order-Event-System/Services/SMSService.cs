using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_6_Assignment_CSharp_Order_Event_System.Services
{
    using System;

    public class SMSService
    {
        public void SendSMS(Order order)
        {
            Console.WriteLine("SMS sent to customer");
        }
    }
}
