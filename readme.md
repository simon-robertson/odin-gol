A Game of Life test using the Odin programming language.

The source code is not really optimized, I just wanted to get something up and running quickly.

There is no support for Windows in this repository.

You will need to have [Odin](https://odin-lang.org/) installed.

You will also need to install SDL3:

```
brew install sdl3
```

You may need to allow the SH files to be executed:

```
chmod +x ./run.sh
chmod +x ./run_debug.sh
```

The debug version is quite a lot slower than the non-debug version:

```
./run.sh
```

```
./run_debug.sh
```

The game state updates are CPU-bound, so are the raw pixel updates, but the raw pixels are mem-copied to the GPU to update what's rendered in the OS window.
