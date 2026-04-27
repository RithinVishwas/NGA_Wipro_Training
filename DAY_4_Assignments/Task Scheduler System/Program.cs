using System;
using System.Collections.Generic;

class Program
{
    static void Main()
    {
        Queue<string> taskQueue = new Queue<string>();
        Stack<string> undoStack = new Stack<string>();
        List<string> allTasks = new List<string>();
        SortedDictionary<int, string> priorityTasks = new SortedDictionary<int, string>();
        HashSet<string> uniqueTasks = new HashSet<string>();

        // ADD TASKS
        Console.Write("Enter number of tasks: ");
        int n = int.Parse(Console.ReadLine());

        for (int i = 0; i < n; i++)
        {
            Console.WriteLine($"\nTask {i + 1}:");

            Console.Write("Enter task name: ");
            string task = Console.ReadLine();

            // Check duplicate
            if (!uniqueTasks.Add(task))
            {
                Console.WriteLine("Duplicate task ignored");
                continue;
            }

            Console.Write("Enter priority (lower number = higher priority): ");
            int priority = int.Parse(Console.ReadLine());

            // Add to collections
            taskQueue.Enqueue(task);
            allTasks.Add(task);

            // Handle duplicate priority
            while (priorityTasks.ContainsKey(priority))
                priority++;

            priorityTasks.Add(priority, task);
        }

        // EXECUTE TASKS
        Console.WriteLine("\nExecuting Tasks:");
        while (taskQueue.Count > 0)
        {
            string currentTask = taskQueue.Dequeue();
            Console.WriteLine("Executing: " + currentTask);

            undoStack.Push(currentTask);
        }

        // UNDO
        Console.Write("\nDo you want to undo last task? (yes/no): ");
        string choice = Console.ReadLine().ToLower();

        if (choice == "yes" && undoStack.Count > 0)
        {
            string undone = undoStack.Pop();
            Console.WriteLine("Undo Task: " + undone);

            allTasks.Remove(undone);

            // remove from priority list
            foreach (var key in new List<int>(priorityTasks.Keys))
            {
                if (priorityTasks[key] == undone)
                {
                    priorityTasks.Remove(key);
                    break;
                }
            }
        }

        // DISPLAY ALL TASKS
        Console.WriteLine("\nAll Tasks:");
        foreach (var t in allTasks)
        {
            Console.WriteLine(t);
        }

        // DISPLAY PRIORITY TASKS
        Console.WriteLine("\nTasks by Priority:");
        foreach (var p in priorityTasks)
        {
            Console.WriteLine("Priority      Task ");
            Console.WriteLine(p.Key + "         -   " + p.Value);
        }

        // DISPLAY REMAINING UNDO STACK
        Console.WriteLine("\nRemaining Tasks in Undo Stack:");
        foreach (var t in undoStack)
        {
            Console.WriteLine(t);
        }
    }
}