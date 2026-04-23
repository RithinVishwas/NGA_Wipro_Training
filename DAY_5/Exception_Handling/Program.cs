using System;

// Custom Exception
public class InvalidAgeException : Exception
{
    public InvalidAgeException(string message) : base(message)
    {
    }
}

class Program
{
    static void Main()
    {
        try
        {
            Console.WriteLine("Enter age:");
            int age = Convert.ToInt32(Console.ReadLine());

            if (age < 18)
            {
                throw new InvalidAgeException("Age must be 18 or above");
            }

            Console.WriteLine("Valid age");
        }
        catch (InvalidAgeException ex)
        {
            Console.WriteLine("Custom Exception: " + ex.Message);
        }
    }
}