using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ServerRssAuto
{
    using System;
    using System.IO;
    using System.Net;
    using System.Runtime.CompilerServices;
    using System.Text;
    using System.Threading;

    class Server
    {
        public static string content;
        private HttpListener listener;

        public Server()
        {
            content = "";
            this.listener = new HttpListener();
        }

        private static void ProcessHttpClient(object obj)
        {
            try
            {
                HttpListenerContext context = obj as HttpListenerContext;
                HttpListenerRequest request = context.Request;
                HttpListenerResponse response = context.Response;
                string content = Server.content;
                byte[] bytes = Encoding.UTF8.GetBytes(content);
                response.ContentLength64 = bytes.Length;
                Stream outputStream = response.OutputStream;
                outputStream.Write(bytes, 0, bytes.Length);
                outputStream.Close();
            }
            catch (System.Exception ex)
            {
                System.Console.WriteLine("fuck the error");
            }
            
        }

        private void realStart()
        {
            this.listener.Prefixes.Add("http://*:7778/");
            this.listener.Start();
            Console.WriteLine("Listening");
            try
            {
                while (true)
                {
                    HttpListenerContext state = this.listener.GetContext();
                    ThreadPool.QueueUserWorkItem(new WaitCallback(Server.ProcessHttpClient), state);
                }
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception.Message);
            }
            finally
            {
                this.listener.Stop();
            }
        }

        public void start()
        {
            new Thread(new ThreadStart(this.realStart)).Start();
            Thread.Sleep(1);
        }

    }
}
