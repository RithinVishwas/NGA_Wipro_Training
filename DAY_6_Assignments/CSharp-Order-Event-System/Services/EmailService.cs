using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_6_Assignment_CSharp_Order_Event_System.Services
{
    using System;

    public class EmailService
    {
        public void SendEmail(Order order)
        {
            Console.WriteLine("Email sent to customer");
        }
    }
}
