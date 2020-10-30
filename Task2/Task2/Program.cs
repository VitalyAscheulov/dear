using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Task2
{
    class Program
    {
        [ThreadStatic]
        private static int _counter;

        static bool KeepGoing = true;
        static List<Task> OngoingTasks = new List<Task>();

        static void Main(string[] args)
        {
            HttpListener listener = new HttpListener();
            listener.Prefixes.Add("http://localhost:1234/");
            listener.Start();
            ProcessAsync(listener).ContinueWith(async task => { await Task.WhenAll(OngoingTasks.ToArray()); });

            var cmd = Console.ReadLine();

            if (cmd.Equals("q", StringComparison.OrdinalIgnoreCase))
            {
                KeepGoing = false;
            }

            Console.ReadLine();
        }

        static async Task ProcessAsync(HttpListener listener)
        {
            while (KeepGoing)
            {
                HttpListenerContext context = await listener.GetContextAsync();
                HandleRequestAsync(context);
            }
        }

        static async Task HandleRequestAsync(HttpListenerContext context)
        {
            Console.WriteLine($"start thread={Thread.CurrentThread.ManagedThreadId} time={DateTime.Now}");
            await Task.Delay(5000);
            Console.WriteLine($"end thread={Thread.CurrentThread.ManagedThreadId} time={DateTime.Now}");
            Perform(context);
        }

        static void Perform(HttpListenerContext ctx)
        {
            HttpListenerResponse response = ctx.Response;
            string responseString = $"<HTML><BODY> Thread {Thread.CurrentThread.ManagedThreadId}, request {_counter} </BODY></HTML>";
            byte[] buffer = Encoding.UTF8.GetBytes(responseString);

            response.ContentLength64 = buffer.Length;
            Stream output = response.OutputStream;
            output.Write(buffer, 0, buffer.Length);

            output.Close();
            _counter++;
        }
    }
}
