using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_2.Factory
{
    public class WordDocument : IDocument
    {
        public void Open()
        {
            Console.WriteLine("Word Document Opened");
        }
    }
}