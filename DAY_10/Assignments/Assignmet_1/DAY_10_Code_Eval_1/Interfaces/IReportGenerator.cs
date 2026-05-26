using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_1.Interfaces
{
    public interface IReportGenerator
    {
        string GenerateReport(string title, string content);
    }
}