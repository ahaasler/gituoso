# gituoso

An improved git terminal

## Installation

In terminal:

    git clone https://github.com/ahaasler/gituoso.git ~/.gituoso

Add this to the end your .bashrc file

    . ~/.gituoso/gituoso.bash

> **NOTE:**
> If you download the project in another location you may need to modify the lines in gituoso.bash where the git-components are sourced

## Configuration

### Arrows

To use arrows instead of ^ and v in the branch summary, change the next line in gituoso.bash to true

    export GITUOSO_USEARROWS=true

> **NOTE:**
> Those arrows are unicode characters, enabling this may show weird characters when using the reverse-i-search. If you don't care use the arrows, they look awesome!

### Prompt reset

> **See also:** [Issue #1](https://github.com/ahaasler/gituoso/issues/1)

Gituoso usually appends itself to your current prompt. If your prompt was already setting the window title you could miss the gituoso extras. To prevent this from happening you can enable this configuration property in gituoso.bash:

    export GITUOSO_RESETPROMPT=true

> **NOTE:** This will change your prompt to "user@host:/path/to/dir$", feel free to change this for your liking.
