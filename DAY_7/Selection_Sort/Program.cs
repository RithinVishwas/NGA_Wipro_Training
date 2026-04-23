using System;

class SelectionSortProgram
{
    static void SelectionSort(int[] arr)
    {
        for (int i = 0; i < arr.Length - 1; i++)
        {
            int minIndex = i;

            for (int j = i + 1; j < arr.Length; j++)
            {
                if (arr[j] < arr[minIndex])
                    minIndex = j;
            }

            int temp = arr[minIndex];
            arr[minIndex] = arr[i];
            arr[i] = temp;
        }
    }

    static void Main()
    {
        Console.Write("Enter array size: ");
        int n = int.Parse(Console.ReadLine());

        int[] arr = new int[n];

        Console.WriteLine("Enter elements:");
        for (int i = 0; i < n; i++)
        {
            arr[i] = int.Parse(Console.ReadLine());
        }

        SelectionSort(arr);

        Console.WriteLine("Sorted Array (Selection Sort):");
        foreach (int num in arr)
            Console.Write(num + " ");
    }
}