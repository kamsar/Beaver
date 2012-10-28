
$class = @"
namespace PS.Build {
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Security;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;

    public class CollectionLogger : Logger
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
"@

Add-Type -TypeDefinition $class -Language CSharp -ReferencedAssemblies @("Microsoft.Build", "Microsoft.Build.Framework", "Microsoft.Build.Utilities.v4.0")