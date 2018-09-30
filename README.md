# Slovim (SLVM) - Smalltalk Lowlevel VIrtual Machine
#### SSA based compiler infrastructure written in Pharo

Slovim is an SSA based framework for building compiler middle ends, and compiler
backends in Pharo. The SSA IR in Slovim is heavily based on the IR that is used
by LLVM, and in fact many instructions have a one-to-one mapping. However, the
advantage of having the SSA in Pharo is that it allows for easy extensibility,
for implementing features

## Installation

**Pharo 7**

```smalltalk
Metacello new
	baseline: 'Slovim';
	repository: 'github://ronsaldo/slovim/tonel';
	load
```

## SLVM backends

Slovim currently have backends for the following targets. Some of them are not
completely supported/implemented, so they still are not able to translate all
of the valid SLVM instructions.

- LLVM textual IR. For feeding into clang/llc.
- Spir-V for Vulkan GPU shaders.
- x86/x86_64 machine code assembly. (Experimental)
- Stack based code generation
    - Standard Pharo bytecode.
    - Pharo bytecode with Lowcode.
