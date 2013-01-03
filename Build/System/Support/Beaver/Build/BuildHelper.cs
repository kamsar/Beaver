using System;
using System.Collections.Generic;
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
				return new BuildResult(new string[] { "Couldn't resolve build file $($projectPath)." }, false);
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

			var logger = new MSBuildCollectionLogger();
			var buildRequest = new BuildRequestData(projectPath, properties, toolsVersion, targets, null);
			var projects = new ProjectCollection();

			projects.RegisterLogger(logger);

			var parameters = new BuildParameters(projects);

			parameters.Loggers = projects.Loggers;

			var result = BuildManager.DefaultBuildManager.Build(parameters, buildRequest);

			return new BuildResult(logger.Messages, result.OverallResult == BuildResultCode.Success);
		}

		private class MSBuildCollectionLogger : Logger
		{
			private List<string> _messages = new List<string>();
			public override void Initialize(IEventSource eventSource)
			{
				eventSource.ProjectStarted += new ProjectStartedEventHandler(eventSource_ProjectStarted);
				eventSource.TaskStarted += new TaskStartedEventHandler(eventSource_TaskStarted);
				eventSource.MessageRaised += new BuildMessageEventHandler(eventSource_MessageRaised);
				eventSource.WarningRaised += new BuildWarningEventHandler(eventSource_WarningRaised);
				eventSource.ErrorRaised += new BuildErrorEventHandler(eventSource_ErrorRaised);
				eventSource.ProjectFinished += new ProjectFinishedEventHandler(eventSource_ProjectFinished);
			}

			public ReadOnlyCollection<string> Messages { get { return _messages.AsReadOnly(); } }

			void eventSource_ErrorRaised(object sender, BuildErrorEventArgs e)
			{
				string line = String.Format("ERROR: {0}({1},{2}): ", e.File, e.LineNumber, e.ColumnNumber);
				WriteLine(line, e);
			}

			void eventSource_WarningRaised(object sender, BuildWarningEventArgs e)
			{
				string line = String.Format("WARNING: {0}({1},{2}): ", e.File, e.LineNumber, e.ColumnNumber);
				WriteLine(line, e);
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
					WriteLine(String.Empty, e);
				}
			}

			void eventSource_TaskStarted(object sender, TaskStartedEventArgs e)
			{
			}

			void eventSource_ProjectStarted(object sender, ProjectStartedEventArgs e)
			{
				WriteLine(String.Empty, e);
			}

			void eventSource_ProjectFinished(object sender, ProjectFinishedEventArgs e)
			{
				WriteLine(String.Empty, e);
			}

			private void WriteLine(string line, BuildEventArgs e)
			{
				string message = line + e.Message;
				_messages.Add(message);
			}
		}
	}
}
