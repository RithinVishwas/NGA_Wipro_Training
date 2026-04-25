using System;
using System.Collections.Generic;

class Student
{
    public string Name;
    public int Marks;
    public int Attendance;
    public int Participation;
}

class Program
{
    //delegate creation
    delegate void StudentEvaluator(Student s);

    static void Main()
    {
        List<Student> students = new List<Student>();

        Console.Write("Enter number of students: ");
        int n = Convert.ToInt32(Console.ReadLine());

        // Input from user
        for (int i = 0; i < n; i++)
        {
            Console.WriteLine($"\nEnter details for Student {i + 1}");

            Student s = new Student();

            Console.Write("Name: ");
            s.Name = Console.ReadLine();

            Console.Write("Marks: ");
            s.Marks = Convert.ToInt32(Console.ReadLine());

            Console.Write("Attendance: ");
            s.Attendance = Convert.ToInt32(Console.ReadLine());

            Console.Write("Participation: ");
            s.Participation = Convert.ToInt32(Console.ReadLine());

            students.Add(s);
        }

        StudentEvaluator evaluate = delegate (Student s)  //anonymous method
        {
            int total = s.Marks + s.Attendance + s.Participation;

            Console.WriteLine("\nStudent: " + s.Name);
            Console.WriteLine("Total Score: " + total);
        };

        Console.WriteLine("\n=== Student Evaluation ==="); // delegate calls anonymous method
        foreach (var s in students)
        {
            evaluate(s);
        }
        Console.WriteLine("\n=== Eligible Students (Marks > 50) ===");    //used lambda expression -to check eligibility
        foreach (var s in students)
        {
            if (s.Marks > 50)
                Console.WriteLine(s.Name);
        }
        Console.WriteLine("\n=== Filtered Students (Marks > 50) ===");   ////used lambda expression -to filter students
        List<Student> filtered = students.FindAll(s => s.Marks > 50);

        foreach (var s in filtered)
        {
            Console.WriteLine(s.Name);
        }
    }