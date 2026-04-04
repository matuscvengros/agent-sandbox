#!/bin/bash
set -e

claude plugin marketplace add git@github.com:matuscvengros/claude-mako-plugins.git
claude plugin install mako@claude-mako-plugins
