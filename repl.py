#!/Users/Orien/anaconda/bin/python
import imp
g = imp.load_source('g', './g')
temp_filename = "temp_script.g"
def repl():
    lines = []
    while True:
        try:
            input_str = str(raw_input())
            if input_str == "clear":
                lines = []
                continue
            lines.append(input_str + "\n")
            with open(temp_filename, "w") as temp_source:
                temp_source.write("".join(lines))
            g.compile_and_run(temp_filename, False)
        except OSError: # Failed to compile
            pass
        

if __name__ == "__main__":
    repl()
