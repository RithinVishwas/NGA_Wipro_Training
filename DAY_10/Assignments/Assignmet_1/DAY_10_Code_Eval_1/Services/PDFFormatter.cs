using DAY_10_Code_Eval_1.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_1.Services
{
    public class PDFFormatter : IReportFormatter
    {
        public string Format(string content)
        {
            return $"PDF FORMAT:\n{content}";
        }
    }
}