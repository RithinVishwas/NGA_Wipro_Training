using System;
using System.Collections.Generic;
using System.Text;
using DAY_10_Code_Eval_1.Interfaces;

namespace DAY_10_Code_Eval_1.Services
{
    public class ReportService
    {
        private readonly IReportGenerator _reportGenerator;

        private readonly IReportSaver _reportSaver;

        private readonly IReportFormatter _reportFormatter;

        public ReportService(
            IReportGenerator reportGenerator,
            IReportSaver reportSaver,
            IReportFormatter reportFormatter)
        {
            _reportGenerator = reportGenerator;
            _reportSaver = reportSaver;
            _reportFormatter = reportFormatter;
        }

        public void CreateAndSaveReport(
            string title,
            string content,
            string filePath)
        {
            string report =
                _reportGenerator.GenerateReport(title, content);

            string formattedReport =
                _reportFormatter.Format(report);

            _reportSaver.SaveReport(formattedReport, filePath);

            Console.WriteLine("Report Generated Successfully!");
        }
    }
}