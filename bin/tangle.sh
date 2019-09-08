#!/usr/bin/bash
# runs tangle.el but also auto executes all src blocks
# no more annoying prompts.

yes yes | $(dirname "$0")/tangle.el
