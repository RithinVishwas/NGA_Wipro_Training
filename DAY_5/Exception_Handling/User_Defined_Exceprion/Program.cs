using System;

class SleepChecker
{
    public void CheckSleepTime()
    {
        Console.WriteLine("Enter your sleeping time (0–23 format):");

        if (int.TryParse(Console.ReadLine(), out int hour))
        {
            if (hour >= 0 && hour <= 23)
            {
                if (hour >= 0 && hour <= 4)
                {
                    Console.WriteLine("Sleeping too late is not healthy!");
                }
                else
                {
                    Console.WriteLine("Good sleep schedule");
                }
            }
            else
            {
                Console.WriteLine("Please enter a valid hour (0–23).");
            }
        }
        else
        {
            Console.WriteLine("Invalid input. Enter a number.");
        }

        Console.WriteLine("Sleep check completed.");
    }
}

class Program
{
    static void Main()
    {
        SleepChecker obj = new SleepChecker();
        obj.CheckSleepTime();
    }
}