using System;
using System.Collections.Generic;

class Program
{
    static void Main()
    {
        LinkedList<string> playlist = new LinkedList<string>();
        SortedList<int, string> ratings = new SortedList<int, string>();
        SortedDictionary<string, string> artistSongs = new SortedDictionary<string, string>();

        // ADD SONGS
        Console.Write("Enter number of songs: ");
        int n = int.Parse(Console.ReadLine());

        for (int i = 0; i < n; i++)
        {
            Console.WriteLine($"\nSong {i + 1}:");

            Console.Write("Enter song name: ");
            string song = Console.ReadLine();

            Console.Write("Enter artist name: ");
            string artist = Console.ReadLine();

            Console.Write("Enter rating (1-5): ");
            int rating = int.Parse(Console.ReadLine());

            // LinkedList
            playlist.AddLast(song);

            // SortedList (handle duplicate rating)
            while (ratings.ContainsKey(rating))
                rating++;

            ratings.Add(rating, song);

            // SortedDictionary
            artistSongs[artist] = song;
        }

        // SEARCH
        Console.Write("\nEnter song to search: ");
        string search = Console.ReadLine();

        if (playlist.Contains(search))
            Console.WriteLine("Song found");
        else
            Console.WriteLine("Song not found");

        // REMOVE
        Console.Write("\nEnter song to remove: ");
        string removeSong = Console.ReadLine();

        if (playlist.Remove(removeSong))
        {
            // remove from ratings
            foreach (var key in new List<int>(ratings.Keys))
            {
                if (ratings[key] == removeSong)
                {
                    ratings.Remove(key);
                    break;
                }
            }

            // remove from artist mapping
            foreach (var key in new List<string>(artistSongs.Keys))
            {
                if (artistSongs[key] == removeSong)
                {
                    artistSongs.Remove(key);
                    break;
                }
            }

            Console.WriteLine("Song removed successfully");
        }
        else
        {
            Console.WriteLine("Song not found");
        }

        // DISPLAY PLAYLIST
        Console.WriteLine("\nPlaylist:");
        foreach (var song in playlist)
        {
            Console.WriteLine(song);
        }

        // DISPLAY SORTED BY RATING
        Console.WriteLine("\nSongs Sorted by Rating:");
        foreach (var item in ratings)
        {
            Console.WriteLine("Rating      Songs ");
            Console.WriteLine( item.Key + "        -   " + item.Value);
        }

        // DISPLAY ARTIST-WISE
        Console.WriteLine("\nArtist-wise Songs:");
        foreach (var item in artistSongs)
        {
            Console.WriteLine(item.Key + " - " + item.Value);
        }
    }
}