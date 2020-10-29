using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace Task1
{

    public class MessageContainer
    {
        private List<Message> messages;

        public MessageContainer()
        {
            var locale = CultureInfo.CurrentCulture.Name;
            messages = GetMessages(File.ReadAllText(@$"{locale}.json")).ToList();
        }

        public Message this[MsgCodes index]
        {
            get { return messages[(int)index]; }
            set { messages[(int)index] = value; }
        }

        public List<Message> GetMessages(string json)
        {
            List<Message> res = new List<Message>();
            using var doc = JsonDocument.Parse(json);
            JsonElement root = doc.RootElement;
            var messages = root.EnumerateObject();

            while (messages.MoveNext())
            {
                var message = messages.Current;
                Enum.TryParse(message.Name, out MsgCodes msgcode);
                var value = message.Value.ToString();
                res.Add(new Message(){MsgCode = msgcode, Value = value});
            }

            return res;
        }
    }
}