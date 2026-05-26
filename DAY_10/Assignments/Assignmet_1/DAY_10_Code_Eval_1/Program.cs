using System;
using DAY_10_Code_Eval_1.Interfaces;
using DAY_10_Code_Eval_1.Services;

namespace DAY_10_Code_Eval_1
{
    class Program
    {
        static void Main(string[] args)
        {
            // Common Dependencies

            IReportGenerator generator =
                new ReportGenerator();

            IReportSaver saver =
                new ReportSaver();

            // ================= PDF REPORT =================

            IReportFormatter pdfFormatter =
                new PDFFormatter();

            string pdfReport =
                generator.GenerateReport(
                    "Monthly Report",
                    "Sales increased by 20%");

            string formattedPdfReport =
                pdfFormatter.Format(pdfReport);

            saver.SaveReport(
                formattedPdfReport,
                "PDF_Report.txt");

            Console.WriteLine("===== PDF REPORT =====");
            Console.WriteLine(formattedPdfReport);

            // ================= EXCEL REPORT =================

            IReportFormatter excelFormatter =
                new ExcelFormatter();

            string excelReport =
                generator.GenerateReport(
                    "Monthly Report",
                    "Sales increased by 20%");

            string formattedExcelReport =
                excelFormatter.Format(excelReport);

            saver.SaveReport(
                formattedExcelReport,
                "Excel_Report.txt");

            Console.WriteLine();
            Console.WriteLine("===== EXCEL REPORT =====");
            Console.WriteLine(formattedExcelReport);

            Console.WriteLine();
            Console.WriteLine("Both reports generated successfully!");

            Console.ReadLine();
        }
    }
}