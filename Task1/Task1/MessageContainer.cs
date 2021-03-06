﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace Task1
{

    public class MessageContainer
    {
        private List<Message> _messages;

        public MessageContainer()
        {
            var locale = CultureInfo.CurrentCulture.Name;
            _messages = GetMessages(File.ReadAllText(@$"{locale}.json")).ToList();
        }

        public string this[MsgCodes index] => _messages[(int)index].Value;
        private List<Message> GetMessages(string json)
        {
            List<Message> result = new List<Message>();
            var doc = JsonDocument.Parse(json);
            JsonElement root = doc.RootElement; 
            var msg = root.EnumerateObject();

            while (msg.MoveNext())
            {
                var message = msg.Current;
                Enum.TryParse(message.Name, out MsgCodes msgcode);
                var value = message.Value.ToString();
                result.Add(new Message(){MsgCode = msgcode, Value = value});
            }

            return result;
        }
    }
}