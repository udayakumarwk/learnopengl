package engine 

import glfw "vendor:glfw"
import "core:fmt"
import "core:c"
import gl "vendor:OpenGL"
import "base:runtime"

//global constants

MAIN_WINDOW_HEIGHT :i32= 600
MAIN_WINDOW_WIDTH  :i32= 800
GL_MAJOR_VERSION   :: 4
GL_MINOR_VERSION   :: 6

mainWindow :glfw.WindowHandle

callBack_struct :: proc(window: glfw.WindowHandle, width, height:i32)

callback_window_resize:callBack_struct

window_size_callback ::proc(callback:callBack_struct){
    callback_window_resize = callback
    glfw.SetWindowSizeCallback(mainWindow, window_size_callback_c)
    

}


init_window :: proc() -> glfw.WindowHandle
{
    if(!glfw.Init())
    {
        fmt.println("Failed to init GLFW")
        return nil
    }

    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)   

    mainWindow = glfw.CreateWindow(MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT, "Graphics Engine", nil, nil)

    if(mainWindow == nil)
    {
        fmt.println("Failed to create window ")
        glfw.Terminate()
        return nil
    }

    glfw.SwapInterval(1)
    glfw.MakeContextCurrent(mainWindow)
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
    gl.Enable(gl.DEPTH_TEST);  

    if(mainWindow == nil)
    {
        fmt.panicf("Aborting..")
    }
    
    return mainWindow
}

should_stop_running :: proc() -> b32
{
    return glfw.WindowShouldClose(mainWindow)
}

terminate_window:: proc()
{
    defer glfw.Terminate()
    defer glfw.DestroyWindow(mainWindow)
}

swap_buffers :: proc()
{
    glfw.SwapBuffers(mainWindow)
}



window_size_callback_c :: proc "c" (window: glfw.WindowHandle, width, height: c.int)
{
    gl.Viewport(0, 0, width, height)
    MAIN_WINDOW_HEIGHT = height
    MAIN_WINDOW_WIDTH = width
    
    context = runtime.default_context();
    callback_window_resize(mainWindow, MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT) 
    // fmt.println("Resizing screen: Width:", width, " Height: ",height)
}