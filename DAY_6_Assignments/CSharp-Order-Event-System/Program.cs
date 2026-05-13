using DAY_6_Assignment_CSharp_Order_Event_System;
using DAY_6_Assignment_CSharp_Order_Event_System.Services;
using System;

class Program
{
    static void Main()
    {
        OrderProcessor processor = new OrderProcessor();

        EmailService email = new EmailService();
        SMSService sms = new SMSService();
        LoggerService logger = new LoggerService();

        processor.OnOrderPlaced += email.SendEmail;
        processor.OnOrderPlaced += sms.SendSMS;
        processor.OnOrderPlaced += logger.LogOrder;

        Console.Write("Enter Order ID: ");
        int id = int.Parse(Console.ReadLine());

        Console.Write("Enter Customer Name: ");
        string name = Console.ReadLine();

        Console.Write("Enter Amount: ");
        double amount = double.Parse(Console.ReadLine());

        Order order = new Order
        {
            OrderId = id,
            CustomerName = name,
            Amount = amount
        };

        processor.ProcessOrder(order);
    }
}