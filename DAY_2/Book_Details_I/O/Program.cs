using System;

class Book
{
  
    public string Title { get; set; }
    public string Author { get; set; }
    public int Year { get; set; }

  
    public Book(string title, string author, int year)
    {
        Title = title;
        Author = author;
        Year = year;
    }
}

class Program
{
    static void Main(string[] args)
    {
      
        Console.WriteLine("Enter book's title:");
        string title = Console.ReadLine();

       
        Console.WriteLine("Enter book's author:");
        string author = Console.ReadLine();

    
        Console.WriteLine("Enter book's year:");
        int year = Convert.ToInt32(Console.ReadLine());

        Book book = new Book(title, author, year);


        Console.WriteLine("\nBook Details:");
        Console.WriteLine("Book's Title: " + book.Title);
        Console.WriteLine("Book'sAuthor: " + book.Author);
        Console.WriteLine("Book's Year: " + book.Year);
    }
}