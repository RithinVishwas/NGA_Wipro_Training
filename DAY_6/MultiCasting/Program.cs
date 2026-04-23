using System;

public delegate void MultiDelegate(int a, int b);

public class MulticastDemo
{
    public static void Add(int a, int b)
    {
        Console.WriteLine("Addition: " + (a + b));
    }

    public static void Subtract(int a, int b)
    {
        Console.WriteLine("Subtraction: " + (a - b));
    }

    public static void Multiply(int a, int b)
    {
        Console.WriteLine("Multiplication: " + (a * b));
    }
}