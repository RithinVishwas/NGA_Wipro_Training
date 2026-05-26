using System;
using System.Collections.Generic;
using System.Text;

using DAY_10_Code_Eval_1.Interfaces;

namespace DAY_10_Code_Eval_1.Models
{
    public class Report : IReport
    {
        public string Title { get; set; }

        public string Content { get; set; }

        public virtual void Generate()
        {
            Console.WriteLine("Generating Generic Report...");
        }
    }
}
