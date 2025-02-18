package engine

import "core:fmt"
import glfw "vendor:glfw"

deltaTime:f64
vbo_list:[dynamic]u32
vao_list:[dynamic]u32
eio_list:[dynamic]u32

Keys :: struct{
    w:bool,
    a:bool,
    s:bool,
    d:bool
}

init_engine :: proc()
{
    init_window()
    
}

terminate_engine :: proc()
{
    terminate_window()
}

