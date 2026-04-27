using System;
using System.Collections.Generic;

class Program
{
    static void Main()
    {
        List<string> posts = new List<string>();
        Dictionary<string, int> likes = new Dictionary<string, int>();
        HashSet<int> users = new HashSet<int>();
        Stack<string> actions = new Stack<string>();
        Queue<string> notifications = new Queue<string>();

        // USERS
        Console.Write("Enter number of users: ");
        int u = int.Parse(Console.ReadLine());

        for (int i = 0; i < u; i++)
        {
            Console.Write("Enter User ID: ");
            int id = int.Parse(Console.ReadLine());

            if (users.Add(id))
                Console.WriteLine("User added");
            else
                Console.WriteLine("Duplicate user ignored");
        }

        // POSTS
        Console.Write("\nEnter number of posts: ");
        int p = int.Parse(Console.ReadLine());

        for (int i = 0; i < p; i++)
        {
            Console.Write("Enter post content: ");
            string post = Console.ReadLine();

            posts.Add(post);
            likes[post] = 0;

            actions.Push($"CREATE:{post}");
            notifications.Enqueue($"New post added: {post}");
        }

        // LIKES
        Console.Write("\nEnter post to like: ");
        string inputPost = Console.ReadLine().ToLower();

        string matchedPost = null;

        foreach (var post in posts)
        {
            if (post.ToLower() == inputPost)
            {
                matchedPost = post;
                break;
            }
        }

        if (matchedPost != null)
        {
            Console.Write("How many likes to give: ");
            int likeCount = int.Parse(Console.ReadLine());

            for (int i = 0; i < likeCount; i++)
            {
                likes[matchedPost]++;
                actions.Push($"LIKE:{matchedPost}");
            }

            notifications.Enqueue($"Your post '{matchedPost}' got {likeCount} like(s)");
        }
        else
        {
            Console.WriteLine("Post not found");
        }

        // UNDO
        Console.Write("\nDo you want to undo last action? (yes/no): ");
        string undoChoice = Console.ReadLine();

        if (undoChoice.ToLower() == "yes" && actions.Count > 0)
        {
            string lastAction = actions.Pop();

            string[] parts = lastAction.Split(':');
            string actionType = parts[0];
            string post = parts[1];

            if (actionType == "LIKE" && likes[post] > 0)
            {
                likes[post]--;
                Console.WriteLine($"Undo Like on '{post}'");
            }
            else if (actionType == "CREATE")
            {
                posts.Remove(post);
                likes.Remove(post);
                Console.WriteLine($"Undo Post Creation '{post}'");
            }
        }

        // NOTIFICATIONS
        Console.WriteLine("\nNotifications:");
        while (notifications.Count > 0)
        {
            Console.WriteLine(notifications.Dequeue());
        }

        // POSTS & LIKES
        Console.WriteLine("\nPosts & Likes:");
        foreach (var post in posts)
        {
            Console.WriteLine($"{post} - {likes[post]} likes");
        }

        // USERS
        Console.WriteLine("\nUnique Users:");
        foreach (var user in users)
        {
            Console.WriteLine(user);
        }

        // ACTION HISTORY
        Console.WriteLine("\nRemaining Actions in Stack:");
        foreach (var act in actions)
        {
            Console.WriteLine(act);
        }
    }
}