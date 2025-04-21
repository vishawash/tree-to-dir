#!/usr/bin/env fish

function parse_tree_and_create
    set -l filename $argv[1]
    set -l stack ""
    set -l indent_stack ""
    set -l base_dir (pwd)

    for line in (cat $filename)
        # Remove comments and whitespace
        set line (string replace -r '#.*$' '' -- $line | string trim)

        if test -z "$line"
            continue
        end

        if not string match -rq '├──|└──' $line
            continue
        end

        # Calculate indentation and get name
        set -l raw_indent (string match -r '^[│ ]*' -- $line)
        set -l indent (string length -- $raw_indent)
        set -l name (string trim -- (string replace -r '^.*── ' '' -- $line))

        while test (count $indent_stack) -gt 0
            set -l top_indent $indent_stack[-1]

            # Check if it's actually a number
            if string match -qr '^[0-9]+$' -- $top_indent
                if test $indent -le $top_indent
                    set -e stack[-1]
                    set -e indent_stack[-1]
                else
                    break
                end
            else
                break
            end
        end

        set stack $stack $name
        set indent_stack $indent_stack $indent

        set -l path $base_dir
        for part in $stack
            set path "$path"/$part
        end

        if string match -q '*/' -- $name
            mkdir -p $path
        else
            mkdir -p (path dirname $path)
            touch $path
        end
    end
end

if test (count $argv) -eq 0
    echo "Usage: ./tree_to_dir.fish tree.txt"
else
    parse_tree_and_create $argv[1]
end
