using System;

namespace DelegateSimple
{
    // Declare delegate: takes 2 ints, returns int
    delegate int MathOperation(int a, int b);

    class Calculator
    {
        public int Add(int a, int b)
        { 
            return a + b;
        }
        public int Subtract(int a, int b) 
        { 
            return a - b;
        }
        public int Multiply(int a, int b) 
        { 
            return a * b;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Calculator calc = new Calculator();

            // Assign methods to delegates
            MathOperation add = calc.Add;
            MathOperation subtract = calc.Subtract;
            MathOperation multiply = calc.Multiply;

            int a = 7, b = 5;

            Console.WriteLine("a = " + a + ", b = " + b);
            Console.WriteLine("Add      : " + add(a, b));
            Console.WriteLine("Subtract : " + subtract(a, b));
            Console.WriteLine("Multiply : " + multiply(a, b));
        }
    }
}