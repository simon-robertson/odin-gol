package app

import "core:math/rand"
import "core:mem"
import "vendor:sdl3"

GRID_SIZE_X :: 256
GRID_SIZE_Y :: 256
GRID_CELL_COUNT :: GRID_SIZE_X * GRID_SIZE_Y

State :: struct {
    cells_1: [GRID_CELL_COUNT]u8,
    cells_2: [GRID_CELL_COUNT]u8,
    pixels:  [GRID_CELL_COUNT * 4]u8, // 4 color channels per pixel
    swapped: bool,
}

state: State

run :: proc() {
    if !sdl3.Init(sdl3.INIT_EVENTS | sdl3.INIT_VIDEO) {
        panic("Failed to initialize SDL3")
    }

    window := sdl3.CreateWindow(
        "Odin GOL",
        GRID_SIZE_X * 3,
        GRID_SIZE_Y * 3,
        sdl3.WINDOW_INPUT_FOCUS,
    )

    if window == nil {
        panic("Failed to create the window")
    }

    renderer := sdl3.CreateRenderer(window, nil)

    if renderer == nil {
        panic("Failed to create the renderer")
    }

    texture := sdl3.CreateTexture(
        renderer,
        sdl3.PixelFormat.RGBA32,
        sdl3.TextureAccess.STREAMING, // streaming allows fast mem-copy data uploads
        GRID_SIZE_X,
        GRID_SIZE_Y,
    )

    if texture == nil {
        panic("Failed to create the texture")
    }

    sdl3.SetTextureScaleMode(texture, sdl3.ScaleMode.NEAREST)
    sdl3.SetRenderVSync(renderer, 1)

    rand_state(&state)
    draw_state(&state, texture)

    event: sdl3.Event

    time_frame: sdl3.Time = 50_000_000 // 50 milliseconds, 20 updates per seconds
    time_current: sdl3.Time
    time_previous: sdl3.Time
    time_elapsed: sdl3.Time

    main: for {
        if !sdl3.GetCurrentTime(&time_current) {
            //
        }

        if time_previous > 0 {
            time_elapsed += time_current - time_previous
        }

        time_previous = time_current

        for sdl3.PollEvent(&event) {
            if event.type == .QUIT {
                break main
            }
        }

        if time_elapsed >= time_frame {
            time_elapsed -= time_frame

            next_state(&state)
            draw_state(&state, texture)
        }

        sdl3.RenderTexture(renderer, texture, nil, nil)
        sdl3.RenderPresent(renderer)
    }

    sdl3.DestroyTexture(texture)
    sdl3.DestroyRenderer(renderer)
    sdl3.DestroyWindow(window)
    sdl3.Quit()
}

rand_state :: proc(state: ^State) {
    assert(state != nil)

    for i := 0; i < len(state.cells_1); i += 1 {
        state.cells_1[i] = rand.float32() > 0.5 ? 1 : 0
    }

    state.swapped = false
}

next_state :: proc(state: ^State) {
    assert(state != nil)

    src: ^[GRID_CELL_COUNT]u8
    dst: ^[GRID_CELL_COUNT]u8

    if !state.swapped {
        src = &state.cells_1
        dst = &state.cells_2
        state.swapped = true
    } else {
        src = &state.cells_2
        dst = &state.cells_1
        state.swapped = false
    }

    for i := 0; i < GRID_CELL_COUNT; i += 1 {
        x := i % GRID_SIZE_X
        y := i / GRID_SIZE_X

        v := get_cell_value(x, y, src)

        c := u8(0)
        c += get_cell_value(x - 1, y - 1, src)
        c += get_cell_value(x + 0, y - 1, src)
        c += get_cell_value(x + 1, y - 1, src)
        c += get_cell_value(x - 1, y + 0, src)
        c += get_cell_value(x + 1, y + 0, src)
        c += get_cell_value(x - 1, y + 1, src)
        c += get_cell_value(x + 0, y + 1, src)
        c += get_cell_value(x + 1, y + 1, src)

        if v > 0 {
            if c < 2 || c > 3 {
                v = 0
            }
        } else if v == 0 && c == 3 {
            v = 1
        }

        dst[i] = v
    }
}

get_cell_value :: proc(x: int, y: int, cells: ^[GRID_CELL_COUNT]u8) -> u8 {
    vx := x
    vy := y

    if vx < 0 {
        vx += GRID_SIZE_X
    } else if vx >= GRID_SIZE_X {
        vx -= GRID_SIZE_X
    }

    if vy < 0 {
        vy += GRID_SIZE_Y
    } else if vy >= GRID_SIZE_Y {
        vy -= GRID_SIZE_Y
    }

    i := vx + (vy * GRID_SIZE_X)

    return cells[i]
}

draw_state :: proc(state: ^State, texture: ^sdl3.Texture) {
    assert(state != nil)
    assert(texture != nil)

    cells: ^[GRID_CELL_COUNT]u8

    if !state.swapped {
        cells = &state.cells_1
    } else {
        cells = &state.cells_2
    }

    cell: u8

    for i := 0; i < GRID_CELL_COUNT; i += 1 {
        cell = cells[i]
        state.pixels[(i << 2) + 0] = cell > 0 ? 255 : 0
        state.pixels[(i << 2) + 1] = cell > 0 ? 255 : 0
        state.pixels[(i << 2) + 2] = cell > 0 ? 255 : 0
        state.pixels[(i << 2) + 3] = 255
    }

    gpu_mem: rawptr
    gpu_tmp: i32

    if sdl3.LockTexture(texture, nil, &gpu_mem, &gpu_tmp) {
        mem.copy(gpu_mem, &state.pixels, GRID_CELL_COUNT << 2)
        sdl3.UnlockTexture(texture)
    }
}
