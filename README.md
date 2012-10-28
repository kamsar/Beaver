# Project X

Work in progress stab at a high performance flexible build system for .NET projects (emphasis on Sitecore) based in PowerShell.

Uses a system of "build pipelines" to define sets of tasks, combined with a flexible setup to create pipelines to run on a per-archetype (e.g. "Content Managment," "Indexing Server," etc) or per-environment (e.g. Dev-CM, Live-Indexing)

Supports "buildlets" interchangeably written in PowerShell, MSBuild, XDT (Microsoft Config Transforms), or Overlay (replaces a file).

Possible support for sub-pipelines for complex sub-tasks.