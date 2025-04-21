#!/usr/bin/env fish

# Check for input argument
if test (count $argv) -ne 1
    echo "Usage: create_structure_from_tree.fish <tree_file>"
    exit 1
end

set treefile $argv[1]

if not test -f $treefile
    echo "Error: File '$treefile' not found."
    exit 1
end

echo "🔧 Parsing $treefile and creating directory structure..."

set cleaned_paths (cat $treefile | \
    sed 's/│//g; s/├── //g; s/└── //g' | \
    sed 's/#.*$//' | \
    awk '{$1=$1};1' | \
    grep -v '^\s*$')

for path in $cleaned_paths
    # If it's a directory
    if string match -q '*/' $path
        mkdir -p $path
        echo "📁 Created directory: $path"
    else
        mkdir -p (dirname $path)
        touch $path
        echo "📄 Created file: $path"
    end
end

echo "✅ Done."
