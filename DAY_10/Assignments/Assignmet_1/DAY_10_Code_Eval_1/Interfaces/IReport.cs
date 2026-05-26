using System;
using System.Collections.Generic;
using System.Text;

namespace DAY_10_Code_Eval_1.Interfaces
{
    public interface IReport
    {
        string Title { get; set; }

        string Content { get; set; }

        void Generate();
    }
}