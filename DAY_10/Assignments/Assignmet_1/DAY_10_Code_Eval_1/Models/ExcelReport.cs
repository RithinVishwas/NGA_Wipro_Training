using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_1.Models
{
    public class ExcelReport : Report
    {
        public override void Generate()
        {
            Console.WriteLine("Generating Excel Report...");
        }
    }
}