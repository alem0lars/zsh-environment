#!/usr/bin/env zsh
#
# {{{ File header. #############################################################
#                                                                              #
# File informations:                                                           #
# - Name:    zsh-environment.zsh                                               #
# - Summary: Sets general shell options and defines environment variables.     #
# - Authors:                                                                   #
#   - Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)              #
#                                                                              #
# Project informations:                                                        #
#   - Homepage:        https://github.com/alem0lars/zsh-environment            #
#   - Getting started: see README.md in the project root folder                #
#                                                                              #
# License: Apache v2.0 (see below)                                             #
#                                                                              #
################################################################################
#                                                                              #
# Licensed to the Apache Software Foundation (ASF) under one more contributor  #
# license agreements.  See the NOTICE file distributed with this work for      #
# additional information regarding copyright ownership. The ASF licenses this  #
# file to you under the Apache License, Version 2.0 (the "License"); you may   #
# not use this file except in compliance with the License.                     #
# You may obtain a copy of the License at                                      #
#                                                                              #
#   http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT    #
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.             #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
#                                                                              #
# }}} ##########################################################################


# {{{ General.

setopt BRACE_CCL       # Allow brace character class list expansion.
setopt COMBINING_CHARS # Combine 0-length punctuation chars with the base char.
setopt RC_QUOTES       # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
unsetopt MAIL_WARNING  # Don't print warn msg if a mail file has been accessed.

# }}}

# {{{ Smart urls.

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# }}}

# {{{ Jobs.

setopt LONG_LIST_JOBS # List jobs in the long format by default.
setopt AUTO_RESUME    # Try to resume existing job before creating a new proc.
setopt NOTIFY         # Report status of background jobs immediately.
unsetopt BG_NICE      # Don't run all background jobs at a lower priority.
unsetopt HUP          # Don't kill jobs on shell exit.
unsetopt CHECK_JOBS   # Don't report on jobs when shell exit.

# }}}

# {{{ Termcap.

export LESS_TERMCAP_mb=$'\E[01;31m'    # Begins blinking.
export LESS_TERMCAP_md=$'\E[01;31m'    # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'        # Ends mode.
export LESS_TERMCAP_se=$'\E[0m'        # Ends standout-mode.
export LESS_TERMCAP_so=$'\E[00;47;30m' # Begins standout-mode.
export LESS_TERMCAP_ue=$'\E[0m'        # Ends underline.
export LESS_TERMCAP_us=$'\E[01;32m'    # Begins underline.

# }}}

# {{{ Aliases and shortcuts

if [[ $OSTYPE == darwin* && $commands[gls] ]]; then
  alias l="gls --color=auto"
elif [[ $OSTYPE == linux* ]]; then
  alias l="ls --color=auto"
fi
type l > /dev/null
if [[ $? -eq 0 ]]; then
  alias ll="l -lsh"
  alias la="ll -a"
fi

alias -g E="$EDITOR"

alias -g G="| grep"
alias -g L="| less -r"

if [[ $commands[xclip] ]]; then
  alias -g C="| xclip -i -selection clipboard"
elif [[ $commands[pbcopy] ]]; then
  alias -g C="| pbcopy"
fi
if [[ $commands[xclip] ]]; then
  alias -g P="xclip -o -selection clipboard |"
elif [[ $commands[pbpaste] ]]; then
  alias -g P="pbpaste |"
fi

# }}}

# In OSX merge the shell PATH with the global PATH (retrieved from launchctl).
if [[ `uname` == 'Darwin' ]]; then
path_builder="
path = (ENV['PATH'] + ':' + \`launchctl getenv PATH\`)
    .split(':')
    .map { |p| p.chomp }
    .uniq
    .compact
scores = [
  ENV['HOME'],
  '/usr/local/(?![s]?bin)',
  '/usr/local/bin',
  '/usr',
  '/'
]
find_score = lambda do |p|
  scores.find_index { |e| Regexp.new('^' + e).match(p) } || scores.length
end
puts path.sort { |p1, p2| find_score[p1] <=> find_score[p2] }.join(':')
"
export PATH="$(/usr/bin/ruby -e $path_builder)"
fi

# vim: set filetype=zsh :