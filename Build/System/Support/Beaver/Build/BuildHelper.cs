using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.IO;
using Microsoft.Build;
using System.Xml;
using Microsoft.Build.Execution;
using Microsoft.Build.Evaluation;
using Microsoft.Build.Utilities;
using Microsoft.Build.Framework;
using System.Collections.ObjectModel;

namespace Beaver.Build
{
	public static class BuildHelper
	{
		public static BuildResult BuildProject(string projectPath, string configuration, string[] targets, Dictionary<string, string> properties, string toolsVersion)
		{
			if (!File.Exists(projectPath))
			{
				throw new ArgumentException("Project path " + projectPath + " did not exist.");
			}

			if (string.IsNullOrEmpty(toolsVersion))
				toolsVersion = "4.0";

			if (properties == null)
				properties = new Dictionary<string, string>();

			if (!properties.ContainsKey("Configuration") && !string.IsNullOrWhiteSpace(configuration))
				properties.Add("Configuration", configuration);

			if (targets == null)
			{
				var doc = new XmlDocument();
				doc.LoadXml(File.ReadAllText(projectPath));

				XmlNode defaultTargets = doc.SelectSingleNode("/Project[@DefaultTargets]");

				if (defaultTargets != null) targets = defaultTargets.Value.Split(';');
			}

			var logger = new MsBuildCollectionLogger();
			var buildRequest = new BuildRequestData(projectPath, properties, toolsVersion, targets, null);
			var projects = new ProjectCollection();

			projects.RegisterLogger(logger);

			var parameters = new BuildParameters(projects);

			parameters.Loggers = projects.Loggers;

			Debug.Assert(targets != null, "dsfsdsf");
			logger.AddMessage(new Message(string.Format("Building {0} ({1}), {2} targets using {3} tools", projectPath, configuration, string.Join(", ", targets), toolsVersion), MessageType.Info));

			var result = BuildManager.DefaultBuildManager.Build(parameters, buildRequest);

			return new BuildResult(logger.Messages, result.OverallResult == BuildResultCode.Success);
		}

		private class MsBuildCollectionLogger : Logger
		{
			private readonly List<Message> _messages = new List<Message>();

			public override void Initialize(IEventSource eventSource)
			{
				if(eventSource == null) throw new ArgumentNullException("eventSource");

				eventSource.ProjectStarted += eventSource_ProjectStarted;
				eventSource.MessageRaised += eventSource_MessageRaised;
				eventSource.WarningRaised += eventSource_WarningRaised;
				eventSource.ErrorRaised += eventSource_ErrorRaised;
				eventSource.ProjectFinished += eventSource_ProjectFinished;
			}

			public void AddMessage(Message message)
			{
				_messages.Add(message);
			}

			public ReadOnlyCollection<Message> Messages { get { return _messages.AsReadOnly(); } }

			void eventSource_ErrorRaised(object sender, BuildErrorEventArgs e)
			{
				string line = String.Format("{0}({1},{2}): ", e.File, e.LineNumber, e.ColumnNumber);
				WriteLine(line, e, MessageType.Error);
			}

			void eventSource_WarningRaised(object sender, BuildWarningEventArgs e)
			{
				string line = String.Format("WARNING: {0}({1},{2}): ", e.File, e.LineNumber, e.ColumnNumber);
				WriteLine(line, e, MessageType.Warning);
			}

			void eventSource_MessageRaised(object sender, BuildMessageEventArgs e)
			{
				// BuildMessageEventArgs adds Importance to BuildEventArgs 
				// Lets take account of the verbosity setting weve been passed in deciding whether to log the message 
				if ((e.Importance == MessageImportance.High && IsVerbosityAtLeast(LoggerVerbosity.Minimal))
					|| (e.Importance == MessageImportance.Normal && IsVerbosityAtLeast(LoggerVerbosity.Normal))
					|| (e.Importance == MessageImportance.Low && IsVerbosityAtLeast(LoggerVerbosity.Detailed))
					)
				{
					WriteLine(String.Empty, e, MessageType.Info);
				}
			}

			void eventSource_ProjectStarted(object sender, ProjectStartedEventArgs e)
			{
				WriteLine(String.Empty, e, MessageType.Info);
			}

			void eventSource_ProjectFinished(object sender, ProjectFinishedEventArgs e)
			{
				WriteLine(String.Empty, e, MessageType.Info);
			}

			private void WriteLine(string line, BuildEventArgs e, MessageType type)
			{
				string message = line + e.Message;
				_messages.Add(new Message(message, type));
			}
		}
	}
}
