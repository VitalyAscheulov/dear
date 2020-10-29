using System;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Task2
{
    class Program
    {
        private static HttpListener _listener;
        [ThreadStatic]
        private static int _counter;

        static void Main(string[] args)
        {
            _listener = new HttpListener();
            _listener.Prefixes.Add("http://localhost:1234/");
            _listener.Start();
            _listener.BeginGetContext(OnContext, null);

            Console.ReadLine();
        }

        private static void OnContext(IAsyncResult ar)
        {
            var ctx = _listener.EndGetContext(ar);
            _listener.BeginGetContext(OnContext, null);
            Console.WriteLine($"{DateTime.UtcNow} Handling request");

            var buf = Encoding.ASCII.GetBytes($"<HTML><BODY> Thread {Thread.CurrentThread.ManagedThreadId}, request {_counter} </BODY></HTML>");
            ctx.Response.ContentType = "text/html";

            // simulate work
            Thread.Sleep(10000);

            ctx.Response.OutputStream.Write(buf, 0, buf.Length);
            ctx.Response.OutputStream.Close();

            Console.WriteLine($"{DateTime.UtcNow} finished");
            _counter++;
        }

    }
}
