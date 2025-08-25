#!/bin/bash
# shellcrypt.sh

VERSION="2.0.0"
TOOL_NAME="ShellCrypt"
GITHUB_URL="https://github.com/Anon4You/ShellCrypt.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Show banner with figlet
show_banner() {
  figlet -f slant "${TOOL_NAME}"
  echo -e "${CYAN}${TOOL_NAME} v${VERSION} - Code Obfuscation and Decoding Tool${NC}"
    echo
}

# Show usage information
show_help() {
    show_banner
    cat << EOF
Usage: $(basename $0) [OPTIONS] FILE

Options:
  -o, --obfuscate    Obfuscate the code (default)
  -d, --decode       Decode obfuscated code
  -t, --type TYPE    Specify code type (bash/python/auto)
  -O, --output FILE  Output file (default: auto-generated in current directory)
  -h, --help         Show this help message
  -v, --version      Show version information

Examples:
  $(basename $0) script.sh                 # Obfuscate bash script
  $(basename $0) -d obfuscated.py          # Decode python script
  $(basename $0) -t python script.py -O custom_output.py
  $(basename $0) -d -t bash obfuscated.sh
EOF
}

# Generate output filename
generate_output_filename() {
    local input_file="$1"
    local action="$2" # "obfuscate" or "decode"
    local file_type="$3"
    
    local filename=$(basename "$input_file")
    local name_no_ext="${filename%.*}"
    local ext="${filename##*.}"
    
    if [ "$ext" = "$filename" ]; then
        # No extension found
        if [ "$file_type" = "python" ]; then
            ext="py"
        else
            ext="sh"
        fi
    fi
    
    if [ "$action" = "obfuscate" ]; then
        echo "${name_no_ext}_ob.${ext}"
    else
        echo "${name_no_ext}_dc.${ext}"
    fi
}

# Add credits to file
add_credits() {
    local file="$1"
    local tool_name="$2"
    local version="$3"
    local github_url="$4"
    local action="$5" # "obfuscated" or "decoded"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Extract shebang from original file
    local shebang=""
    if head -n 1 "$file" | grep -q "^#!"; then
        shebang=$(head -n 1 "$file")
        tail -n +2 "$file" > "${temp_file}.content"
    else
        # If no shebang, use appropriate default
        if grep -q "#!/bin/bash\|#!/bin/sh" "$file" 2>/dev/null || \
           grep -q "echo\|if\|then\|fi\|do\|done" "$file" 2>/dev/null; then
            shebang="#!/bin/bash"
        elif grep -q "#!/usr/bin/env python\|#!/usr/bin/python" "$file" 2>/dev/null || \
             grep -q "import\|def\|class\|print" "$file" 2>/dev/null; then
            shebang="#!/usr/bin/env python3"
        else
            shebang="#!/bin/bash"
        fi
        cat "$file" > "${temp_file}.content"
    fi
    
    # Build the file with shebang, credits, and content
    echo "$shebang" > "$temp_file"
    echo "# ${action^} by $tool_name, v$version" >> "$temp_file"
    echo "# GitHub: $github_url" >> "$temp_file"
    cat "${temp_file}.content" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
    rm -f "${temp_file}.content"
}

# Detect file type based on extension or content
detect_file_type() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Check by extension first
    case "$filename" in
        *.sh|*.bash)
            echo "bash"
            return 0
            ;;
        *.py|*.python)
            echo "python"
            return 0
            ;;
        *)
            # Try to detect by content
            if head -n 5 "$file" | grep -q "#!/bin/bash\|#!/bin/sh"; then
                echo "bash"
            elif head -n 5 "$file" | grep -q "#!/usr/bin/env python\|#!/usr/bin/python"; then
                echo "python"
            elif head -n 5 "$file" | grep -q "import\|def\|class"; then
                echo "python"
            elif head -n 5 "$file" | grep -q "echo\|if\|then\|fi\|do\|done"; then
                echo "bash"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Obfuscate bash code using bash-obfuscate
obfuscate_bash() {
    local input_file="$1"
    local output_file="$2"
    
    if ! command -v bash-obfuscate &> /dev/null; then
        echo -e "${RED}Error: bash-obfuscate not found. Please install it first.${NC}"
        exit 1
    fi
    
    bash-obfuscate "$input_file" > "$output_file"
    add_credits "$output_file" "$TOOL_NAME" "$VERSION" "$GITHUB_URL" "obfuscated"
    echo -e "${GREEN}Bash code obfuscated and saved to: $output_file${NC}"
}

# Decode bash code using the specified method
decode_bash() {
    local input_file="$1"
    local output_file="$2"
    
    # Create temporary file with eval replaced by echo
    local temp_file=$(mktemp)
    sed 's/eval/echo/' "$input_file" > "$temp_file"
    
    # Make temporary file executable
    chmod +x "$temp_file"
    
    # Run the modified script and capture output
    "$temp_file" > "$output_file" 2>/dev/null
    add_credits "$output_file" "$TOOL_NAME" "$VERSION" "$GITHUB_URL" "decoded"
    echo -e "${GREEN}Bash code decoded and saved to: $output_file${NC}"
    
    # Clean up temporary file
    rm -f "$temp_file"
}

# Obfuscate python code using emojify
obfuscate_python() {
    local input_file="$1"
    local output_file="$2"
    
    if ! command -v emojify &> /dev/null; then
        echo -e "${RED}Error: emojify not found. Please install it first.${NC}"
        exit 1
    fi
    
    emojify --input "$input_file" --output "$output_file" --emoji
    add_credits "$output_file" "$TOOL_NAME" "$VERSION" "$GITHUB_URL" "obfuscated"
    echo -e "${GREEN}Python code obfuscated and saved to: $output_file${NC}"
}

# Decode python code using the specified method
decode_python() {
    local input_file="$1"
    local output_file="$2"
    
    # Create temporary file with exec replaced by print
    local temp_file=$(mktemp)
    sed 's/exec/print/' "$input_file" > "$temp_file"
    
    # Run the modified script and capture output
    python3 "$temp_file" > "$output_file" 2>/dev/null
    add_credits "$output_file" "$TOOL_NAME" "$VERSION" "$GITHUB_URL" "decoded"
    echo -e "${GREEN}Python code decoded and saved to: $output_file${NC}"
    
    # Clean up temporary file
    rm -f "$temp_file"
}

# Main function
main() {
    local action="obfuscate"
    local file_type="auto"
    local input_file=""
    local output_file=""
    local show_banner_flag=0
    
    # Check if any arguments were provided
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--obfuscate)
                action="obfuscate"
                show_banner_flag=1
                shift
                ;;
            -d|--decode)
                action="decode"
                show_banner_flag=1
                shift
                ;;
            -t|--type)
                file_type="$2"
                show_banner_flag=1
                shift 2
                ;;
            -O|--output)
                output_file="$2"
                show_banner_flag=1
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo -e "${CYAN}ShellCrypt v${VERSION}${NC}"
                exit 0
                ;;
            -*)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
            *)
                input_file="$1"
                show_banner_flag=1
                shift
                ;;
        esac
    done
    
    # Show banner only if we have valid arguments (not just help/version)
    if [ $show_banner_flag -eq 1 ]; then
        show_banner
    fi
    
    # Validate input
    if [ -z "$input_file" ]; then
        echo -e "${RED}Error: No input file specified${NC}"
        show_help
        exit 1
    fi
    
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: File not found: $input_file${NC}"
        exit 1
    fi
    
    # Detect file type if auto
    if [ "$file_type" = "auto" ]; then
        file_type=$(detect_file_type "$input_file")
        if [ "$file_type" = "unknown" ]; then
            echo -e "${RED}Error: Could not detect file type. Please specify with -t option${NC}"
            exit 1
        fi
        echo -e "${BLUE}Detected file type: $file_type${NC}"
    fi
    
    # Generate output filename if not specified
    if [ -z "$output_file" ]; then
        output_file=$(generate_output_filename "$input_file" "$action" "$file_type")
    fi
    
    # Check if output file already exists
    if [ -f "$output_file" ]; then
        echo -e "${YELLOW}Warning: Output file $output_file already exists. Overwriting...${NC}"
    fi
    
    # Perform the requested action
    case "$file_type" in
        bash)
            if [ "$action" = "obfuscate" ]; then
                obfuscate_bash "$input_file" "$output_file"
            else
                decode_bash "$input_file" "$output_file"
            fi
            ;;
        python)
            if [ "$action" = "obfuscate" ]; then
                obfuscate_python "$input_file" "$output_file"
            else
                decode_python "$input_file" "$output_file"
            fi
            ;;
        *)
            echo -e "${RED}Error: Unsupported file type: $file_type${NC}"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
