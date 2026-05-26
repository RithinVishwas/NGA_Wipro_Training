using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using DAY_10_Code_Eval_1.Interfaces;

namespace DAY_10_Code_Eval_1.Services
{
    public class ReportSaver : IReportSaver
    {
        public void SaveReport(string content, string filePath)
        {
            File.WriteAllText(filePath, content);
        }
    }
}