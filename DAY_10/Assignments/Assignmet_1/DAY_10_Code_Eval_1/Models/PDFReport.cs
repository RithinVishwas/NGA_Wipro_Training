using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_1.Models
{
    public class PDFReport : Report
    {
        public override void Generate()
        {
            Console.WriteLine("Generating PDF Report...");
        }
    }
}