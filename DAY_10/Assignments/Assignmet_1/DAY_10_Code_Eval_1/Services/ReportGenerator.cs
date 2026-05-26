using System;
using System.Collections.Generic;
using System.Text;
using DAY_10_Code_Eval_1.Interfaces;

namespace DAY_10_Code_Eval_1.Services
{
    public class ReportGenerator : IReportGenerator
    {
        public string GenerateReport(string title, string content)
        {
            return $"Report Title: {title}\nContent: {content}";
        }
    }
}