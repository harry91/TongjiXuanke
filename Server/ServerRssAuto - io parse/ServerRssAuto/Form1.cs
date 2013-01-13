using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using Parse;
using System.Collections;


namespace ServerRssAuto
{
    public partial class Form1 : Form
    {
        ParseClient parseEngine;
        Server server;
        private static string url = "http://www.tongji-uni.com/newslist.aspx?intclass=1";
        RSSFeedGenerator gen;
        System.Timers.Timer timer;
        string cate = "外事办";
        int port = 7779;

        struct NSRange
        {
            public int length;
            public int location;
        }

        NSRange rangeOfStr(string str, string tofind)
        {
            int i = str.IndexOf(tofind);
            NSRange r;
            r.length = i >= 0 ? tofind.Length : -1;
            r.location = i;
            return r;
        }


        private string sourceString()
        {
            WebClient client = new WebClient();
            client.Encoding = Encoding.UTF8;
            string downloadString = client.DownloadString(url);
            return downloadString;
        }

        string parse(string source)
        {
            StringWriter stringWriter = new StringWriter();
            string result;
            gen = new RSSFeedGenerator(stringWriter);

            //-------------------------------------------------
            // here is set values for header information for the RSS feed
            //-------------------------------------------------
            gen.Title = cate;
            gen.Description = "";
            gen.LastBuildDate = DateTime.Now;
            gen.Link = "http://sbhhbs.com";
            //gen.Category = "The optional category";
            gen.PubDate = DateTime.Now;


            // write the header of the RSS feed document
            gen.WriteStartDocument();

            // write the start channel for the RSS feed Items
            gen.WriteStartChannel();


            Regex qariRegex = new Regex("<a href='newsshow\\.aspx\\?sn=([0-9]*)'>.([^<]*)<[^(]*\\(([^)]*)\\)");
            MatchCollection mc = qariRegex.Matches(source);
            foreach (Match match in mc)
            {
                string newsid = match.Groups[1].Value;
                string title = match.Groups[2].Value;
                string date = match.Groups[3].Value;


                string content = "";
                var objList = parseEngine.GetObjectsWithQuery("RSS", new { url = newsid });
                bool cateresult = false;
                if (objList != null && objList.Length > 0)
                {
                    foreach (var obj in objList)
                    {
                       
                        if (cate.Equals(obj["category"]))
                        {
                            cateresult = true;
                            break;
                        }
                    }
                    if(cateresult)
                        System.Console.WriteLine("Old item:" + title);
                }
                if(!cateresult)
                {
                    WebClient client = new WebClient();
                    client.Encoding = Encoding.UTF8;
                    String subURL = "http://www.tongji-uni.com/newsshow.aspx?sn=" + newsid;
                    string downloadString = client.DownloadString(subURL);
                    NSRange start = rangeOfStr(downloadString, "<table cellpadding=\"0\" cellspacing=\"2\" border=\"0\" width=\"100%\" class=\"wh\">");
                    NSRange end = rangeOfStr(downloadString, "<P><div align=right><a href=\"default.aspx\">【返回】</a></div></P>");
                    content = downloadString.Substring(start.location, end.location - start.location) + "</td></tr></table>";
                
                    var testObject = new Parse.ParseObject("RSS");
                    testObject["category"] = cate;
                    testObject["url"] = newsid;
                    testObject["title"] = title;
                    testObject["newsTime"] = String.Format("{0:yyyy-MM-dd HH:mm:ss}", DateTime.Parse(date));
                    testObject["content"] = saveTextToParse(content);
                    //Create a new object
                    testObject = parseEngine.CreateObject(testObject);
                    System.Console.WriteLine("New item:" + title);
                }
                

                gen.WriteItem(
                               title,
                               newsid,
                               "",
                               "sbhhbs",
                               "",
                               "",
                               "",
                               DateTime.Parse(date),
                               "",
                               "",
                               "",
                               "");
            }

            
            // end the channel
            gen.WriteEndChannel();
            try
            {
                // end the document
                gen.WriteEndDocument();
            }
            catch (System.Exception ex)
            {
            	
            }
            finally
            {
                // close the rss generator and dispay to screen
                gen.Close();

                result = stringWriter.ToString();
            }
            //result = StringWriter.to
            return result;
        }

        void work()
        {
            Server.content = parse(sourceString());
        }


        public Form1()
        {
            InitializeComponent();
        }

        public void theout(object source,System.Timers.ElapsedEventArgs e)
        {
            work();
        }

        string saveTextToParse(string str)
        {
            ArrayList al = new ArrayList();
            int limitSize = 1024 * 24;
            while (str.Length > limitSize)
            {
                string firstPart = str.Substring(0, limitSize);
                str = str.Substring(limitSize);
                al.Add(firstPart);
            }
            al.Add(str);
            string result = "";
            foreach (string s in al)
            {
                var testObject = new Parse.ParseObject("TextDB");
                testObject["text"] = s;
                //Create a new object
                testObject = parseEngine.CreateObject(testObject);
                result += testObject.objectId + ",";
            }
            return result;
        }



        private void Form1_Load(object sender, EventArgs e)
        {
            label2.Text = cate;
            parseEngine = new ParseClient("fHKruOIrAtqIDOOOWHMUrvhk0dOwjplFOCjdL6CL", "93zxFQDtpRxaw6Y9moOyegqKqTTU8N3GBe42Je9n");

            server = new Server(port);
            Server.content = "";
            server.start();

            timer = new System.Timers.Timer(1000 * 60 * 20);
            timer.Elapsed +=
new System.Timers.ElapsedEventHandler(theout);
            //到达时间的时候执行事件；   
            timer.AutoReset = true;
            //设置是执行一次（false）还是一直执行(true)；   
            timer.Enabled = true; 

            work();
        }

    }
}
