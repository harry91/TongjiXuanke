using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace ServerRssAuto
{
    public class RSSFeedGenerator
    {
        XmlTextWriter writer;

        #region Private Members
        private string _title;
        private string _link;
        private string _description;
        private string _language = "zh-hans";
        private string _copyright = "Copyright " + DateTime.Now.Year.ToString();
        private string _managingEditor;
        private string _webMaster;
        private DateTime _pubDate;
        private DateTime _lastBuildDate;
        private string _category;
        private string _generator = "";
        private string _docs = "";
        private string _rating;
        private string _ttl = "20";
        private string _imgNavigationUrl;
        private string _imgUrl;
        private string _imgTitle;
        private string _imgHeight;
        private string _imgWidth;
        private bool _isItemSummary = false;
        private int _maxCharacters = 300;
        #endregion

        #region Public Members
        /// 
        /// Required - The name of the channel. It's how people refer to your service. If you have an HTML website that contains the same information as your RSS file, the title of your channel should be the same as the title of your website.
        /// 
        public string Title
        {
            get { return _title; }
            set { _title = value; }
        }

        /// 
        /// Required - The URL to the HTML website corresponding to the channel.
        /// 
        public string Link
        {
            get { return _link; }
            set { _link = value; }
        }

        /// 
        /// Required - Phrase or sentence describing the channel.
        /// 
        public string Description
        {
            get { return _description; }
            set { _description = value; }
        }

        /// 
        /// The language the channel is written in.
        /// 
        public string Language
        {
            get { return _language; }
            set { _language = value; }
        }

        /// 
        /// Copyright notice for content in the channel.
        /// 
        public string Copyright
        {
            get { return _copyright; }
            set { _copyright = value; }
        }

        /// 
        /// Email address for person responsible for editorial content.
        /// 
        public string ManagingEditor
        {
            get { return _managingEditor; }
            set { _managingEditor = value; }
        }
        
        /// 
        /// Email address for person responsible for technical issues relating to channel.
        /// 
        public string WebMaster
        {
            get { return _webMaster; }
            set { _webMaster = value; }
        }

        /// 
        /// The publication date for the content in the channel. For example, the New York Times publishes on a daily basis, the publication date flips once every 24 hours. That's when the pubDate of the channel changes. 
        /// 
        public DateTime PubDate
        {
            get { return _pubDate; }
            set { _pubDate = value; }
        }
       
        /// 
        /// The last time the content of the channel changed.
        /// 
        public DateTime LastBuildDate
        {
            get { return _lastBuildDate; }
            set { _lastBuildDate = value; }
        }

        /// 
        /// Specify one or more categories that the channel belongs to.
        /// 
        public string Category
        {
            get { return _category; }
            set { _category = value; }
        }

        /// 
        /// A string indicating the program used to generate the channel.
        /// 
        public string Generator
        {
            get { return _generator; }
            set { _generator = value; }
        }

        /// 
        /// A URL that points to the documentation for the format used in the RSS file.
        /// 
        public string Docs
        {
            get { return _docs; }
            set { _docs = value; }
        }

        /// 
        /// The PICS rating for the channel.
        /// 
        public string Rating
        {
            get { return _rating; }
            set { _rating = value; }
        }
        
        /// 
        /// ttl stands for time to live. It's a number of minutes that indicates how long a channel can be cached before refreshing from the source. 
        /// 
        public string Ttl
        {
            get { return _ttl; }
            set { _ttl = value; }
        }

        /// 
        /// is the URL of the site, when the channel is rendered, the image is a link to the site. (Note, in practice the image 
        public string ImgNavigationUrl
        {
            get { return _imgNavigationUrl; }
            set { _imgNavigationUrl = value; }
        }

        /// 
        /// The URL of a GIF, JPEG or PNG image that represents the channel
        /// 
        public string ImgUrl
        {
            get { return _imgUrl; }
            set { _imgUrl = value; }
        }

        /// 
        /// Describes the image, it's used in the ALT attribute of the HTML  tag when the channel is rendered in HTML. 
        /// 
        public string ImgTitle
        {
            get { return _imgTitle; }
            set { _imgTitle = value; }
        }

        /// 
        /// The height of the image
        /// 
        public string ImgHeight
        {
            get { return _imgHeight; }
            set { _imgHeight = value; }
        }

        /// 
        /// The width of the image
        /// 
        public string ImgWidth
        {
            get { return _imgWidth; }
            set { _imgWidth = value; }
        }

        /// 
        /// Indicates whether to show the full Item description or a summary
        /// 
        public bool IsItemSummary
        {
            get { return _isItemSummary; }
            set { _isItemSummary = value; }
        }

        /// 
        /// Indicates the amount of characters to display in the Item description
        /// 
        public int MaxCharacters
        {
            get { return _maxCharacters; }
            set { _maxCharacters = value; }
        }

        #endregion

        #region Constructors
        
        public RSSFeedGenerator(System.IO.Stream stream, System.Text.Encoding encoding)
        {
            writer = new XmlTextWriter(stream, encoding);
            writer.Formatting = Formatting.Indented;
        }

        public RSSFeedGenerator(System.IO.TextWriter w)
        {
            writer = new XmlTextWriter(w);
            writer.Formatting = Formatting.Indented;
        }
        
        #endregion

        #region Methods
        /// 
        /// Writes the beginning of the RSS document
        /// 
        public void WriteStartDocument()
        {
            //            //
            //            writer.WriteStartDocument();
            //string PItext = "type='text/xsl' href='styles/rss.xsl'";
            //writer.WriteProcessingInstruction("xml-stylesheet", PItext);

            //string PItext2 = "type='text/css' href='styles/rss.css'";
            //writer.WriteProcessingInstruction("xml-stylesheet", PItext2);


            writer.WriteStartElement("rss");
            writer.WriteAttributeString("version", "2.0");
        }
        
        /// 
        /// Writes the end of the RSS document
        /// 
        public void WriteEndDocument()
        {
            writer.WriteEndElement(); //rss
            //writer.WriteEndDocument();
        }
        
        /// 
        /// Closes this stream and the underlying stream
        /// 
        public void Close()
        {
            writer.Flush();
            writer.Close();
        }

        /// 
        /// Writes the beginning of a channel in the RSS document
        /// 
        public void WriteStartChannel()
        {
            try
            {
                writer.WriteStartElement("channel");

                writer.WriteElementString("title", _title);
                writer.WriteElementString("link", _link);
                writer.WriteElementString("description", _description);

                if (!String.IsNullOrEmpty(_language))
                    writer.WriteElementString("language", _language);

                if (!String.IsNullOrEmpty(_copyright))
                    writer.WriteElementString("copyright", _copyright);

                if (!String.IsNullOrEmpty(_managingEditor))
                    writer.WriteElementString("managingEditor", _managingEditor);

                if (!String.IsNullOrEmpty(_webMaster))
                    writer.WriteElementString("webMaster", _webMaster);

                if (_pubDate != null && _pubDate != DateTime.MinValue && _pubDate != DateTime.MaxValue)
                    writer.WriteElementString("pubDate", _pubDate.ToString("r"));

                if (_lastBuildDate != null && _lastBuildDate != DateTime.MinValue && _lastBuildDate != DateTime.MaxValue)
                    writer.WriteElementString("lastBuildDate", _lastBuildDate.ToString("r"));

                if (!String.IsNullOrEmpty(_category))
                    writer.WriteElementString("category", _category);

                if (!String.IsNullOrEmpty(_generator))
                    writer.WriteElementString("generator", _generator);

                if (!String.IsNullOrEmpty(_docs))
                    writer.WriteElementString("docs", _docs);

                if (!String.IsNullOrEmpty(_rating))
                    writer.WriteElementString("rating", _rating);

                if (!String.IsNullOrEmpty(_ttl))
                    writer.WriteElementString("ttl", _ttl);

                if (!String.IsNullOrEmpty(_imgUrl))
                {
                    writer.WriteStartElement("image");
                    writer.WriteElementString("url", _imgUrl);

                    if (!String.IsNullOrEmpty(_imgNavigationUrl))
                        writer.WriteElementString("link", _imgNavigationUrl);

                    if (!String.IsNullOrEmpty(_imgTitle))
                        writer.WriteElementString("title", _imgTitle);

                    if (!String.IsNullOrEmpty(_imgWidth))
                        writer.WriteElementString("width", _imgWidth);

                    if (!String.IsNullOrEmpty(_imgHeight))
                        writer.WriteElementString("height", _imgHeight);

                    writer.WriteEndElement();
                }


            }
            catch (Exception ex)
            {
                throw;
            }

        }
        
        /// 
        /// Writes the end of a channel in the RSS document
        /// 
        public void WriteEndChannel()
        {
            writer.WriteEndElement(); //channel
        }

        /// 
        /// Writes an RSS Feed Item
        /// 
        /// The title of the item.
        /// The URL of the item
        /// The item synopsis.
        /// Email address of the author of the item.
        /// Includes the item in one or more categories
        /// URL of a page for comments relating to the item.
        /// A string that uniquely identifies the item.
        /// Indicates when the item was published.
        /// The URL of the RSS channel that the item came from.
        /// The URL of where the enclosure is located
        /// The length of the enclosure (how big it is in bytes).
        /// The standard MIME type of the enclosure.
        public void WriteItem(string title, string link, string description, string author, string category, 
            string comments, string guid, DateTime pubDate, string source, string encUrl, string encLength, string encType)
        {
            try
            {
                writer.WriteStartElement("item");
                writer.WriteElementString("title", title);
                writer.WriteElementString("link", link);
                writer.WriteRaw("");

                if (!String.IsNullOrEmpty(author))
                    writer.WriteElementString("author", author);

                if (!String.IsNullOrEmpty(category))
                    writer.WriteElementString("category", category);

                if (!String.IsNullOrEmpty(comments))
                    writer.WriteElementString("comments", comments);

                if (!String.IsNullOrEmpty(guid))
                    writer.WriteElementString("guid", guid);

                if (pubDate != null && pubDate != DateTime.MinValue && pubDate != DateTime.MaxValue)
                    writer.WriteElementString("pubDate", pubDate.ToString("r"));

                if (!String.IsNullOrEmpty(source))
                    writer.WriteElementString("description", source);

                if (!String.IsNullOrEmpty(encUrl) && !String.IsNullOrEmpty(encLength) && !String.IsNullOrEmpty(encType))
                {
                    writer.WriteStartElement("enclosure");
                    writer.WriteAttributeString("url", encUrl);
                    writer.WriteAttributeString("length", encLength);
                    writer.WriteAttributeString("type", encType);
                    writer.WriteEndElement();
                }

                writer.WriteEndElement();
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        /// 
        /// Trims the description if necessary
        /// 
        /// 
        /// 
        private string GetDescription(string description)
        {
            if (_isItemSummary)
            {
                if (description == "")
                {
                    return "";
                }
                else
                {
                    if (description.Length > _maxCharacters)
                    {
                        return description.ToString().Substring(0, _maxCharacters) + " ...";
                    }
                    else
                        return description;
                }
            }
            else
                return description;
        }
        
        #endregion
    }
}

