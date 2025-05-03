package main

import "core:fmt"
import "core:mem"
import "source:app"

main :: proc() {
    when ODIN_DEBUG {
        fmt.println("Running ...")

        tracking_allocator: mem.Tracking_Allocator
        mem.tracking_allocator_init(&tracking_allocator, context.allocator)
        context.allocator = mem.tracking_allocator(&tracking_allocator)

        finalize :: proc(allocator: ^mem.Tracking_Allocator) {
            for _, value in allocator.allocation_map {
                fmt.printf("Leaked %v bytes of memory at %v\n", value.size, value.location)
            }

            mem.tracking_allocator_destroy(allocator)
        }

        defer finalize(&tracking_allocator)
    }

    app.run()
}
