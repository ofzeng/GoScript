#!/usr/bin/python
import sys
import os
import subprocess
import repl

def countWhitespace(line):
    count = 0
    for char in line:
        if char == ' ':
            count += 1
        elif char == '\t':
            count += 4
        else:
            break
    return count

def preprocess(filename, compiled_file, compiled_folder):
    expected_whitespace = 0
    lines = []
    foundBeginning = False
    foundPackage = False
    additional_whitespace = 0

    for line in open(filename):
        whitespace = countWhitespace(line)
        stripped = line.strip()
        if len(stripped) == 0:
            whitespace = expected_whitespace
        if whitespace % 4 != 0 and len(stripped) > 0:
            print "Error: bad whitespace"
            print "Line: $" + line + "$" + "whitespace: " + str(whitespace) + " length: " + str(len(line))
            exit()
        if stripped.startswith("package"):
            foundPackage = True
        if stripped != "" and not foundPackage:
            foundPackage = True
            lines.append("package main\nimport \"fmt\"\n")
        while expected_whitespace > whitespace:
            expected_whitespace -= 4
            if expected_whitespace == whitespace and stripped.startswith("else"):
                lines.append("}")
            else:
                lines.append(" " * (expected_whitespace + additional_whitespace) + "}\n")
        if not (foundBeginning or whitespace > 0 or stripped == "" or stripped.startswith("type") or stripped.startswith("package") or stripped.startswith("}") or stripped.startswith("]") or stripped.startswith(")") or stripped.startswith("#") or stripped.startswith("func") or stripped.startswith("import")):
            lines.append("func main() {\n")
            foundBeginning = True
            additional_whitespace += 4
        if stripped.startswith("print "):
            lines.append(" " * additional_whitespace + "fmt.Println(" + stripped.split(" ", 1)[1] + ")\n")
        elif len(stripped) > 0 and not stripped.startswith("//") and stripped[-1] == ':':
            expected_whitespace += 4
            lines.append(" " * additional_whitespace + line[:-2] + ' {' + '\n')
        else:
            lines.append(" " * additional_whitespace + line)

    lines.append('fmt.Print("")')
    if foundBeginning:
        lines.append("}\n")

    with open(compiled_file, "w") as f:
        f.write("".join(lines))

def get_output_paths(filename, verbose):
    compiled_folder = os.path.normpath(os.environ['GOPATH']) + "/src/" # ~/go/src
    name, extension = os.path.splitext(filename) # name = 'path/to/script', extension = '.go'
    name = os.path.basename(name) # name = 'script'
    compiled_folder += "go_temp/" + name # ~/go/src/go_temp/script
    if not os.path.exists(compiled_folder):
        os.makedirs(compiled_folder)
    compiled_file = compiled_folder + "/" + name + ".go" # ~/go/src/go_temp/script/script.go
    executable_file = os.path.normpath(os.environ['GOBIN']) + '/' + name # ~/go/bin/script
    if verbose:
        print compiled_file
    return (compiled_folder, compiled_file, executable_file)

def compile_and_run(filename, verbose = True):
    compiled_folder, compiled_file, executable_file = get_output_paths(filename, verbose)
    if not os.path.exists(executable_file) or os.path.getmtime(executable_file) < os.path.getmtime(filename) or not os.path.exists(compiled_file) or os.path.getmtime(compiled_file) < os.path.getmtime(filename):
        if verbose:
            print "recompiling..."
        preprocess(filename, compiled_file, compiled_folder)
        go_fmt = subprocess.Popen(["gofmt", "-w", compiled_file])
        go_fmt.wait()
        go_install = subprocess.Popen(["go", "install", compiled_file])
        go_install.wait()

    execute = subprocess.Popen([executable_file])
    execute.wait()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        repl.repl()
    else:
        filename = sys.argv[1]
        compile_and_run(filename)

