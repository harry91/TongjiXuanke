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

namespace ServerRssAuto
{
    public partial class Form1 : Form
    {

        Server server;
        private static string url = "http://old.tongji-caup.org/student/News_nmore.asp";
        RSSFeedGenerator gen;
        System.Timers.Timer timer;

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
            client.Encoding = Encoding.Default;
            string downloadString = client.DownloadString(url);
            return downloadString;
        }

        string convertToUTF8fromGB2312(string str)
        {
            Encoding GB2312 = Encoding.GetEncoding("GB2312");
            Encoding utf8 = Encoding.UTF8;
            byte[] gbbytes = GB2312.GetBytes(str);
            byte[] isoBytes = Encoding.Convert(GB2312, utf8, gbbytes);
            return utf8.GetString(isoBytes);
        }

        string parse(string source)
        {
            source = convertToUTF8fromGB2312(source);

            StringWriter stringWriter = new StringWriter();
            string result;
            gen = new RSSFeedGenerator(stringWriter);

            //-------------------------------------------------
            // here is set values for header information for the RSS feed
            //-------------------------------------------------
            gen.Title = "建筑与城市规划";
            gen.Description = "";
            gen.LastBuildDate = DateTime.Now;
            gen.Link = "http://sbhhbs.com";
            //gen.Category = "The optional category";
            gen.PubDate = DateTime.Now;


            // write the header of the RSS feed document
            gen.WriteStartDocument();

            // write the start channel for the RSS feed Items
            gen.WriteStartChannel();


            Regex qariRegex = new Regex("<a href=\"news_detail\\.asp\\?id=([0-9]*)\">([^<]*)");
            MatchCollection mc = qariRegex.Matches(source);
            foreach (Match match in mc)
            {
                string id = match.Groups[1].Value;
                string title = match.Groups[2].Value;
                
                WebClient client = new WebClient();
                client.Encoding = Encoding.Default;
                String subURL = "http://old.tongji-caup.org/student/news_detail.asp?id=" + id;
                string downloadString = client.DownloadString(subURL);
                downloadString = convertToUTF8fromGB2312(downloadString);
                


                string time = "2012-10-3";
                NSRange start = rangeOfStr(downloadString, "发布时间：");
                NSRange end = rangeOfStr(downloadString, "&nbsp;&nbsp; 信息来源：");
                time = downloadString.Substring(start.location+start.length, end.location - start.location - 5);



                start = rangeOfStr(downloadString, "<td  class=\"TLE\">");
                end = rangeOfStr(downloadString, "<!--内容-->");
                string content = downloadString.Substring(start.location, end.location - start.location)+"</td>";
               

                gen.WriteItem(
                               title,
                               id,
                               "",
                               "sbhhbs",
                               "",
                               "",
                               "",
                               DateTime.Parse(time),
                               content,
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


        /*
          NSRange range = [source rangeOfString:@"<td align=\"left\" class=\"TLE\" width=\"736\" valign=\"top\"><span class=\"Hd== NSNotFound\">["];
            if(range.location == NSNotFound)
                break;
            source = [source substringFromIndex:range.location + range.length];
            NSString* date = [source substringToIndex:5];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            if([date hasPrefix:@"0"] && ![date hasPrefix:@"09"])
            {
                date = [@"2013" stringByAppendingString:date];
            }
            else
            {
                date = [@"2012" stringByAppendingString:date];
            }
            [df setDateFormat:@"yyyyMM-dd"];
            NSDate *myDate = [df dateFromString: date];
            
            NSLog(@"news time: %@",myDate);
            range = [source rangeOfString:@"<a href=\"news_detail.asp?id="];
            source = [source substringFromIndex:range.location + range.length];
            NSString *newsURL = [source substringToIndex:4];
            
            range = [source rangeOfString:@"\">"];
            source = [source substringFromIndex:range.location + range.length];
            range = [source rangeOfString:@"</a></td>"];
            NSString* title = [source substringToIndex:range.location];
            
            NSDictionary *item = @{@"url":newsURL, @"title":title, @"date": myDate};
            [dict addObject:item];
         */


        void work()
        {
            Server.content = parse(sourceString());
            label2.Text = DateTime.Now.ToString();
        }


        public Form1()
        {
            InitializeComponent();
        }

        public void theout(object source,System.Timers.ElapsedEventArgs e)
        {
            work();
        }  

        private void Form1_Load(object sender, EventArgs e)
        {
            server = new Server();
            Server.content = "";
            server.start();

            timer = new System.Timers.Timer(1000 * 60 * 15);
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
