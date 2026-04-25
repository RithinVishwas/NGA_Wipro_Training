using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("_____ SYNCHRONOUS EXECUTION _____");
        RunSynchronous();

        Console.WriteLine("_____ ASYNCHRONOUS EXECUTION _____");
        await RunAsynchronous();

        Console.ReadLine();
    }

    static void RunSynchronous()
    {
        Stopwatch sw = Stopwatch.StartNew();

        GetStudentDetails();
        GetMarks();
        GetAttendance();

        sw.Stop();
        Console.WriteLine($"Total Time Sync: {sw.ElapsedMilliseconds} ms");
    }

    static void GetStudentDetails()
    {
        Thread.Sleep(2000);
        Console.WriteLine("Student Details Loaded");
    }

    static void GetMarks()
    {
        Thread.Sleep(2000);
        Console.WriteLine("Marks Loaded");
    }

    static void GetAttendance()
    {
        Thread.Sleep(2000);
        Console.WriteLine("Attendance Loaded");
    }

    static async Task RunAsynchronous()
    {
        Stopwatch sw = Stopwatch.StartNew();

        Task task1 = GetStudentDetailsAsync();
        Task task2 = GetMarksAsync();
        Task task3 = GetAttendanceAsync();

        await Task.WhenAll(task1, task2, task3);

        sw.Stop();
        Console.WriteLine($"Total Time Async: {sw.ElapsedMilliseconds} ms");
    }

    static async Task GetStudentDetailsAsync()
    {
        await Task.Delay(2000);
        Console.WriteLine("Student Details Loaded");
    }

    static async Task GetMarksAsync()
    {
        await Task.Delay(2000);
        Console.WriteLine("Marks Loaded");
    }

    static async Task GetAttendanceAsync()
    {
        await Task.Delay(2000);
        Console.WriteLine("Attendance Loaded");
    }
}