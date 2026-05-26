using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Singleton
{
    public sealed class Logger
    {
        // Single instance

        private static Logger instance = null;

        // Lock object for thread safety

        private static readonly object lockObject = new object();

        // Private constructor

        private Logger()
        {
        }

        // Global access point

        public static Logger GetInstance()
        {
            lock (lockObject)
            {
                if (instance == null)
                {
                    instance = new Logger();
                }

                return instance;
            }
        }

        public void Log(string message)
        {
            Console.WriteLine($"LOG: {message}");
        }
    }
}