using System;
using System.Collections.Generic;


class Customer
{
    public int CustomerId { get; set; }
    public string Name { get; set; }

    public Customer(int id, string name)
    {
        CustomerId = id;
        Name = name;
    }
}

class Order
{
    public int OrderId { get; set; }
    public int CustomerId { get; set; }
    public string ProductCategory { get; set; }
    public Stack<string> StatusHistory { get; set; }

    public Order(int orderId, int customerId, string category)
    {
        OrderId = orderId;
        CustomerId = customerId;
        ProductCategory = category;
        StatusHistory = new Stack<string>();
        StatusHistory.Push("Created"); // Initial status
    }

    public void UpdateStatus(string status)
    {
        StatusHistory.Push(status);
    }

    public string GetCurrentStatus()
    {
        return StatusHistory.Peek();
    }
}


class Program
{
    static void Main()
    {
        
        List<Order> orders = new List<Order>();
        Dictionary<int, Customer> customers = new Dictionary<int, Customer>();
        HashSet<string> categories = new HashSet<string>();
        Queue<Order> orderQueue = new Queue<Order>();

        customers.Add(1, new Customer(1, "Sundar"));
        customers.Add(2, new Customer(2, "Rahul"));

        Order order1 = new Order(101, 1, "Electronics");
        Order order2 = new Order(102, 2, "Clothing");

        orders.Add(order1);
        orders.Add(order2);

        categories.Add(order1.ProductCategory);
        categories.Add(order2.ProductCategory);
        categories.Add("Electronics");

        orderQueue.Enqueue(order1);
        orderQueue.Enqueue(order2);

        Console.WriteLine("---- All Orders ----");
        foreach (var order in orders)
        {
            Console.WriteLine($"Order ID: {order.OrderId}, Customer: {customers[order.CustomerId].Name}, Category: {order.ProductCategory}, Status: {order.GetCurrentStatus()}");
        }

       
        Console.WriteLine("\n---- Updating Order Status ----");
        order1.UpdateStatus("Packed");
        order1.UpdateStatus("Shipped");

        Console.WriteLine($"Order {order1.OrderId} Current Status: {order1.GetCurrentStatus()}");

        Console.WriteLine("\n---- Processing Orders ----");
        while (orderQueue.Count > 0)
        {
            Order current = orderQueue.Dequeue();
            current.UpdateStatus("Delivered");

            Console.WriteLine($"Processed Order {current.OrderId} - Status: {current.GetCurrentStatus()}");
        }

        Console.WriteLine("\n---- Removing Order 102 ----");
        orders.Remove(order2);

        Console.WriteLine("\n---- Remaining Orders ----");
        foreach (var order in orders)
        {
            Console.WriteLine($"Order ID: {order.OrderId}, Status: {order.GetCurrentStatus()}");
        }

        Console.WriteLine("\n---- Unique Product Categories ----");
        foreach (var cat in categories)
        {
            Console.WriteLine(cat);
        }
    }
}