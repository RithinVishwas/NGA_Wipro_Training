using System;
using System.Collections.Generic;
using System.Text;
using DAY_10_Code_Eval_1.Interfaces;

namespace DAY_10_Code_Eval_1.Services
{
    public class ExcelFormatter : IReportFormatter
    {
        public string Format(string content)
        {
            return $"EXCEL FORMAT:\n{content}";
        }
    }
}