#! /bin/bash
set -e
set -x
dart build cli
build/cli/linux_x64/bundle/bin/fints_cli --help > docs/helptext