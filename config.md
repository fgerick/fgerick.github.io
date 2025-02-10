# uncomment and adjust the following line if the expected base URL of your website is something like [www.thebase.com/yourproject/]
# please do read the docs on deployment to avoid common issues: https://franklinjl.org/workflow/deploy/#deploying_your_website
# prepath = "yourproject"

# Add here files or directories that should be ignored by Franklin, otherwise
# these files might be copied and, if markdown, processed by Franklin which
# you might not want. Indicate directories by ending the name with a `/`.
# Base files such as LICENSE.md and README.md are ignored by default.
@def ignore = ["node_modules/"]

# RSS (the website_{title, descr, url} must be defined to get RSS)
@def generate_rss = true
@def website_title = "Felix Gerick"
@def website_descr = "Postdoctoral researcher in Geophysical Fluid Dynamics"
@def website_url   = "https://fgerick.github.io"

@def author = "Felix Gerick"
@def mintoclevel = 2

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->


<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\collapse}[2]{~~~<button class="collapsible">~~~ #1 ~~~</button><div class="collapsiblecontent">~~~ #2 ~~~</div>~~~}

\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
\newcommand{\vec}{\mathbf}
