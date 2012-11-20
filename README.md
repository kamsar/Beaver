# Beaver

Beaver is a flexible build/configure/deploy system for ASP.NET projects based in PowerShell. It is designed to simplify the task of maintaining builds that may span many target environments (such as dev, QA, production) where each has its own slightly different configuration requirements.

Everything in Beaver is based on a consistent, simple idea: the "pipeline." Pipelines are simply a folder that contain "buildlet" files that perform tasks in alphabetical order. Their structure is quite similar to POSIX System V-style init scripts, only instead of a pipeline per runlevel there's a pipeline per build stage. Buildlets can be written in several domain-specific languages (PowerShell, XDT Transform, MSBuild, or even sub-pipelines), and you can implement your own buildlet provider if you wish. Using this architecture allows you to implement small, easily digestable, single-responsibility units of action - as well as gain an immediate understanding of how the build process works by simply looking in a few folders and seeing visually the order things run in and their descriptions.

To manage multiple target environments, Beaver implements a powerful inheritance chain of pipelines. _Archetypes_ are a way to extend the global pipelines to perform a specific sort of configuration that might apply to multiple environments - for example, configuring live error handling or hardening a CMS site's content delivery-type servers. _Environments_ then declare themselves as using 0-n archetypes (in addition to being able to extend the global pipelines themselves), allowing them to inherit cross-environment configurations.

Beaver was originally designed to support build and deploy operations for the [Sitecore CMS](http://sitecore.net). However, Sitecore is merely a set of archetypes - the system can be used for any sort of ASP.NET project.

## How to use Beaver

* Check out [the quickstart](https://github.com/kamsar/Beaver/wiki/Quickstart) for some quick start documentation and more depth than above.
* Review the [fully commented pipeline](https://github.com/kamsar/Beaver/tree/master/Documentation/Fully%20Commented%20Pipeline.pipeline) for heavily commented examples of what a pipeline looks like, and how to format all of the buildlet types available by default in Beaver.
* Read the code. There's no substitute for this if you want to get deep into the guts of how it works.

## Licensing

Beaver is released under the [MIT License](http://opensource.org/licenses/MIT).

## Contribution

Contributions and fixes to Beaver are welcome. Please submit a pull request for consideration.

## Beaver? Huh?

Simple: Beavers are great builders. Yeah, it's cheesy. But it's better than the working name it had before that... ;)