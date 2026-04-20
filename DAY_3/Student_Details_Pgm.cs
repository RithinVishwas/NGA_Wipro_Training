using System;

class Student
{
    
    private string name;
    private int id;

    public Student(string name, int id)
    {
        this.name = name;
        this.id = id;
    }

    public void DisplayInfo()
    {
        Console.WriteLine("Student Name: " + name);
        Console.WriteLine("Student ID: " + id);
    }

    public void UpdateName(string newName)
    {
        name = newName;
    }

    public void UpdateId(int newId)
    {
        id = newId;
    }
}

class Student_Details_Pgm
{
    static void Main()
    {
        Student student1 = new Student("John Doe", 101);
        Student student2 = new Student("Tywin", 102);

        Console.WriteLine("Original Student Details:");
        student1.DisplayInfo();
        student2.DisplayInfo();

        student1.UpdateName("John Snow");
        student1.UpdateId(201);

        student2.UpdateName("Tyrion Lannister");
        student2.UpdateId(202);

        Console.WriteLine("Updated Student Details:");
        student1.DisplayInfo();
        student2.DisplayInfo();
    }
}