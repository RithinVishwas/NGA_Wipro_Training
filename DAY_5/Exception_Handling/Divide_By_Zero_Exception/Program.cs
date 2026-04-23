using System;

class Program
{
    static void Main()
    {
        try
        {
            int a = 10;
            int b = 0;

            int result = a / b;

            Console.WriteLine(result);
        }
        catch (DivideByZeroException)
        {
            Console.WriteLine("Cannot divide by zero");
        }
        finally
        {
            Console.WriteLine("Done");
        }
    }
}