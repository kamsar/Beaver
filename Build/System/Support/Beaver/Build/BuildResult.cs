using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Beaver.Build
{
	public class BuildResult
	{
		internal BuildResult(IEnumerable<string> messages, bool success)
		{
			Messages = messages.ToArray();
			Success = success;
		}

		public string[] Messages { get; private set; }
		public bool Success { get; private set; }
	}
}
