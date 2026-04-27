using System;
using System.Collections.Generic;

class Order
{
    public int OrderId;
    public int CustomerId;
    public string ProductName;
    public string Category;
    public double Price;
}

class Customer
{
    public int CustomerId;
    public string Name;
}

class Program
{
    static void Main()
    {
        List<Order> orders = new List<Order>();
        Dictionary<int, Customer> customers = new Dictionary<int, Customer>();
        HashSet<string> categories = new HashSet<string>();
        Queue<Order> orderQueue = new Queue<Order>();
        Stack<string> orderHistory = new Stack<string>();

        Console.Write("Enter number of customers: ");
        int c = int.Parse(Console.ReadLine());

        for (int i = 0; i < c; i++)
        {
            Console.WriteLine($"\nEnter Customer {i + 1} details:");
            Console.Write("ID: ");
            int id = int.Parse(Console.ReadLine());

            Console.Write("Name: ");
            string name = Console.ReadLine();

            customers[id] = new Customer { CustomerId = id, Name = name };
        }

        Console.Write("\nEnter number of orders: ");
        int n = int.Parse(Console.ReadLine());

        for (int i = 0; i < n; i++)
        {
            Console.WriteLine($"\nEnter Order {i + 1} details:");

            Order o = new Order();

            Console.Write("Order ID: ");
            o.OrderId = int.Parse(Console.ReadLine());

            Console.Write("Customer ID: ");
            o.CustomerId = int.Parse(Console.ReadLine());

            if (!customers.ContainsKey(o.CustomerId))
            {
                Console.WriteLine("Invalid Customer ID. Skipping order.");
                i--;
                continue;
            }

            Console.Write("Product Name: ");
            o.ProductName = Console.ReadLine();

            Console.Write("Category: ");
            o.Category = Console.ReadLine();
            categories.Add(o.Category);

            Console.Write("Price: ");
            o.Price = double.Parse(Console.ReadLine());

            orders.Add(o);
            orderQueue.Enqueue(o);

            orderHistory.Push($"Order {o.OrderId} Created");
        }

        Console.Write("\nEnter Order ID to update: ");
        int updateId = int.Parse(Console.ReadLine());

        var orderToUpdate = orders.Find(o => o.OrderId == updateId);
        if (orderToUpdate != null)
        {
            Console.Write("Enter new price: ");
            orderToUpdate.Price = double.Parse(Console.ReadLine());
            Console.WriteLine("Order Updated");
        }
        else
        {
            Console.WriteLine("Order not found");
        }

        Console.Write("\nEnter Order ID to remove: ");
        int removeId = int.Parse(Console.ReadLine());

        orders.RemoveAll(o => o.OrderId == removeId);

        // Rebuild queue to maintain consistency
        orderQueue = new Queue<Order>(orders);

        Console.WriteLine("\nProcessing Orders:");
        while (orderQueue.Count > 0)
        {
            var current = orderQueue.Dequeue();
            Console.WriteLine($"Processing Order {current.OrderId}");

            orderHistory.Push($"Order {current.OrderId} Processing");
            orderHistory.Push($"Order {current.OrderId} Shipped");
        }

        Console.WriteLine("\nOrder Status History:");
        foreach (var h in orderHistory)
        {
            Console.WriteLine(h);
        }

        Console.WriteLine("\nCustomers:");
        foreach (var cst in customers.Values)
        {
            Console.WriteLine($"ID: {cst.CustomerId}, Name: {cst.Name}");
        }

        Console.WriteLine("\nUnique Categories:");
        foreach (var cat in categories)
        {
            Console.WriteLine(cat);
        }
    }
}