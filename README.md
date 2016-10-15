# Go Scripting Language

## Usage

* Add `g` to the $PATH
* g hello.gs

GoScript features a simple REPL as well, just call `g` with no arguments!

## About

* This language features hybrid syntax between go and python and compiles straight into go code.  This project is mostly intended for small (single-file) scripting projects.
* Write your code anywhere, GoScript will automatically place your compiled code into your go workspace
* GoScript is easy to use: Hello world is just `print "Hello", "World!"`

## Language Features
* Auto import fmt
* Automatically place script body into main()
* Colon and indentation to denote nesting:

```
if 1 == 2:
    print "Hi"
```
