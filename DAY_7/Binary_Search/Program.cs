using System;

class BinarySearchProgram
{
    static int BinarySearch(int[] arr, int key)
    {
        int low = 0, high = arr.Length - 1;

        while (low <= high)
        {
            int mid = low + (high - low) / 2;

            if (arr[mid] == key)
                return mid;
            else if (arr[mid] < key)
                low = mid + 1;
            else
                high = mid - 1;
        }

        return -1;
    }

    static void Main()
    {
        Console.Write("Enter number of elements: ");
        int n = int.Parse(Console.ReadLine());

        int[] arr = new int[n];

        Console.WriteLine("Enter elements:");
        for (int i = 0; i < n; i++)
        {
            arr[i] = int.Parse(Console.ReadLine());
        }

        // Sorting is REQUIRED
        Array.Sort(arr);

        Console.WriteLine("Sorted Array:");
        foreach (int num in arr)
        {
            Console.Write(num + " ");
        }

        Console.Write("\nEnter element to search: ");
        int key = int.Parse(Console.ReadLine());

        int result = BinarySearch(arr, key);

        if (result != -1)
            Console.WriteLine($"\nElement found at index: {result}");
        else
            Console.WriteLine("\nElement not found");
    }
}