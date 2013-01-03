﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Beaver.ConfigTransformation
{
	public class TransformResult
	{
		internal TransformResult(IEnumerable<Message> messages, bool success)
		{
			Messages = messages.ToArray();
			Success = success;
		}

		public Message[] Messages { get; private set; }
		public bool Success { get; private set; }
	}
}
