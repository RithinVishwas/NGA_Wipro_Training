using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Factory
{
    public class DocumentFactory
    {
        public IDocument CreateDocument(string type)
        {
            if (type == "PDF")
            {
                return new PDFDocument();
            }
            else if (type == "WORD")
            {
                return new WordDocument();
            }
            else
            {
                throw new ArgumentException("Invalid document type");
            }
        }
    }
}