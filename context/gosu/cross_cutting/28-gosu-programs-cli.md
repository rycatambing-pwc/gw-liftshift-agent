---
document: gosu-cli-programs
purpose: Writing and running standalone Gosu programs from the command line
scope: .gsp files, Gosu.RawArgs, gosu CLI, limitations
---

# Gosu Programs (CLI)

## Overview

Gosu programs are standalone scripts runnable from the command line — not server-deployed or entity-aware. Useful for utilities, data migration prep, batch file processing, and testing Gosu logic outside the GW container.

## File Extension

Standalone Gosu programs use `.gsp` extension (not `.gs`).

## Running a Program

```bash
gosu myprogram.gsp
gosu myprogram.gsp arg1 arg2 arg3
```

## Accessing Command-Line Arguments

```gosu
var args = Gosu.RawArgs    // String[] of all command-line arguments
if (args.length > 0) {
  var firstArg = args[0]
}
```

## gosu CLI Options

```bash
gosu myprogram.gsp              # run program
gosu -e "1 + 1"                 # evaluate expression inline
gosu -classpath /path/to/jars myprogram.gsp   # add to classpath
gosu -checkedArithmetic myprogram.gsp         # enable checked arithmetic (throws on overflow)
```

## Limitations

CLI Gosu programs **cannot access**:
- Entity types (no database connection)
- PCF types (no UI framework)
- Guidewire server-side APIs requiring running server context

To access entities from a CLI program, use a WS-I web service endpoint:
```gosu
// Call web service instead of direct entity access
var client = new MyEntityServiceClient("http://server/ws/my-service")
var result = client.getPolicy(policyNumber)
```

## Simple Program Example

```gosu
// hello.gsp
print("Hello from Gosu CLI!")
print("Arguments: " + Gosu.RawArgs.join(", "))
```

## File Processing Example

```gosu
// processcsv.gsp
uses java.io.File
uses java.io.BufferedReader
uses java.io.FileReader

var filename = Gosu.RawArgs.length > 0 ? Gosu.RawArgs[0] : "input.csv"
using (var reader = new BufferedReader(new FileReader(new File(filename)))) {
  var line = reader.readLine()
  while (line != null) {
    print("Processing: " + line)
    line = reader.readLine()
  }
}
```

## Agent checks

When reviewing `.gsp` files:

1. Is `Gosu.RawArgs` used correctly (index check before access)?
2. Are entity types accessed? Flag — not available in CLI context.
3. Are resources properly closed with `using` blocks?
4. Is checked arithmetic needed for numeric operations?
