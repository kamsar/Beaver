using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Web.Publishing.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using System.Xml;

namespace Beaver.ConfigTransformation
{
	/// <summary>
	/// Based on https://github.com/jdaigle/TransformXml, thanks!
	/// </summary>
	public static class InPlaceTransformer
	{
		public static TransformResult Transform(string transformationPath, IDictionary<string, string> parameters, string[] targetFiles)
		{
			if (!File.Exists(transformationPath)) throw new ArgumentException("Transformation path did not exist");
			
			if (targetFiles == null || targetFiles.Length == 0) return null;

			foreach (var file in targetFiles)
			{
				if (!File.Exists(file)) throw new ArgumentException("Target file " + file + " did not exist");
			}

			var logger = new CollectionXmlTransformationLogger();
			var transformText = File.ReadAllText(transformationPath);

			transformText = ParameterizeText(transformText, parameters);

			XmlTransformation transformation = new XmlTransformation(transformText, false, logger);

			foreach (var file in targetFiles)
			{
				var input = File.ReadAllText(file);

				XmlTransformableDocument document = new XmlTransformableDocument();
				document.PreserveWhitespace = true;
				
				document.LoadXml(input);
				
				transformation.Apply(document);

				if(logger.HasErrors) break;

				if (document.IsChanged)
				{
					document.Save(file);
				}
			}

			return new TransformResult(logger.Messages.ToArray(), !logger.HasErrors);
		}

		static readonly Regex rePattern = new Regex(@"(\{+)([^\}]+)(\}+)", RegexOptions.Compiled);
		static string ParameterizeText(string input, IDictionary<string, string> parameters)
		{
			if (parameters == null || parameters.Keys.Count == 0) return input;

			return rePattern.Replace(input, match =>
			{
				int lCount = match.Groups[1].Value.Length,
					rCount = match.Groups[3].Value.Length;
				if ((lCount % 2) != (rCount % 2)) throw new InvalidOperationException("Unbalanced braces");
				string lBrace = lCount == 1 ? "" : new string('{', lCount / 2),
					rBrace = rCount == 1 ? "" : new string('}', rCount / 2);

				string key = match.Groups[2].Value, value;
				if (lCount % 2 == 0)
				{
					value = key;
				}
				else
				{
					if (!parameters.TryGetValue(key, out value))
					{
						return string.Empty;
					}
				}

				return lBrace + value + rBrace;
			});
		}

		private class CollectionXmlTransformationLogger : IXmlTransformationLogger
		{
			public CollectionXmlTransformationLogger()
			{
				Messages = new List<string>();
				HasErrors = false;
			}

			public IList<string> Messages { get; private set; }
			public bool HasErrors { get; private set; }

			private void WriteLine(string message, params object[] args)
			{
				if (args != null && args.Length > 0)
					Messages.Add(string.Format(message, args));
				else
					Messages.Add(message);
			}

			public void EndSection(MessageType type, string message, params object[] messageArgs)
			{
				EndSection(message, messageArgs);
			}

			public void EndSection(string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void LogError(string file, int lineNumber, int linePosition, string message, params object[] messageArgs)
			{
				LogError(file, message, messageArgs);
			}

			public void LogError(string file, string message, params object[] messageArgs)
			{
				LogError(file, messageArgs, messageArgs);
			}

			public void LogError(string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
				HasErrors = true;
			}

			public void LogErrorFromException(Exception ex, string file, int lineNumber, int linePosition)
			{
				LogErrorFromException(ex, file);
			}

			public void LogErrorFromException(Exception ex, string file)
			{
				LogErrorFromException(ex);
			}

			public void LogErrorFromException(Exception ex)
			{
				WriteLine(ex.Message);
				WriteLine(ex.StackTrace);
				HasErrors = true;
			}

			public void LogMessage(MessageType type, string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void LogMessage(string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void LogWarning(string file, int lineNumber, int linePosition, string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void LogWarning(string file, string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void LogWarning(string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void StartSection(MessageType type, string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}

			public void StartSection(string message, params object[] messageArgs)
			{
				WriteLine(message, messageArgs);
			}
		}
	}
}
