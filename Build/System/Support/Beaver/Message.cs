namespace Beaver
{
	public class Message
	{
		internal Message(string message, MessageType type)
		{
			Text = message;
			Type = type;
		}

		public string Text { get; private set; }
		public MessageType Type { get; private set; }
	}
}
