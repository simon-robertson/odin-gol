A Game of Life test using the Odin programming language.

The source code is not really optimized, I just wanted to get something up and running quickly.

There is no support for Windows in this repository.

See: https://odin-lang.org

You will Odin and SDL3 installed:

```
brew install odin
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
