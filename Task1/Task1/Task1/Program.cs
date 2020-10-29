using System;
using System.Text.Json;

namespace Task1
{
    class Program
    {
        static void Main(string[] args)
        {
            MessageContainer messageContainer = new MessageContainer();
            var v = messageContainer[MsgCodes.Msg2];
        }

       }
    }

