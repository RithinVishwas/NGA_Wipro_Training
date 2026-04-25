using System;
using System.IO;

class Program
{
    static void Main()
    {
        string filePath = "sample.txt";
        string copyPath = "copy.txt";

        try
        {
            Console.WriteLine("Creating file...");
            File.Create(filePath).Close();

            Console.WriteLine("Writing to file...");
            File.WriteAllText(filePath, "Hello, this is the first line.");

            Console.WriteLine("Appending data...");
            File.AppendAllText(filePath, "\nThis is appended text.");

            Console.WriteLine("\nReading file:");
            string content = File.ReadAllText(filePath);
            Console.WriteLine(content);

            Console.WriteLine("\nCopying file...");
            File.Copy(filePath, copyPath, true);

            Console.WriteLine("Deleting original file...");
            File.Delete(filePath);

            Console.WriteLine("File operations completed.");
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error: " + ex.Message);
        }
    }
}