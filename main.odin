package main

import gl "vendor:OpenGL"
import "base:runtime"
import glfw "vendor:glfw"
import c "core:c"
import "core:fmt"
import stbi "vendor:stb/image"

//global constants

MAIN_WINDOW_HEIGHT :: 600
MAIN_WINDOW_WIDTH  :: 800
GL_MAJOR_VERSION   :: 4
GL_MINOR_VERSION   :: 6

is_wireframe := false

main :: proc()
{

   

    if(!glfw.Init())
    {
        fmt.println("Failed to init GLFW")
        return
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)   

    mainWindow := glfw.CreateWindow(MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT, "Graphics Engine", nil, nil)
    defer glfw.DestroyWindow(mainWindow)

    if(mainWindow == nil)
    {
        fmt.println("Failed to create window ")
        glfw.Terminate()
        return 
    }
    glfw.SwapInterval(1)
    glfw.MakeContextCurrent(mainWindow)
    glfw.SetWindowSizeCallback(mainWindow, window_size_callback)
    glfw.SetKeyCallback(mainWindow, key_callback)

    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    shader := create_shader("shader/vertex.glsl", "shader/fragment.glsl")

    triangle:= [?]f32{
        // positions          // colors           // texture coords
        0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0, // top right
        0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0, // bottom right
       -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0, // bottom left
       -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0  // top left 
         
    }

    vertices:= [?]u32{
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    }
    img_width, img_height, img_chan:i32
    wall_tex := stbi.load("assets/textures/wall.jpg", &img_width, &img_height, &img_chan, 0)
    fmt.println("wall_tex width =", img_width, " height=", img_height)


    vbo, vao, eio, texID:u32

    gl.GenVertexArrays(1,&vao)
    gl.BindVertexArray(vao)

    
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER,vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(triangle)*size_of(triangle[0]), raw_data(&triangle), gl.STATIC_DRAW)
    
    gl.GenBuffers(1, &eio)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER,eio)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(u32) * len(vertices), raw_data(&vertices),gl.STATIC_DRAW)
    //position attribute
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0); 
    //texture attribute
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6)
    gl.EnableVertexAttribArray(1)

    gl.BindVertexArray(0)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.GenTextures(1, &texID)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texID)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    if (wall_tex!=nil)
    {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, img_width, img_height, 0, gl.RGB, gl.UNSIGNED_BYTE, wall_tex);
        gl.GenerateMipmap(gl.TEXTURE_2D);
    }
    else
    {
        fmt.println("Failed to load texture")
    }
    stbi.image_free(wall_tex);
    gl.BindTexture(gl.TEXTURE_2D, 0)
    
    
    fpsLimit :: 1.0 / 60.0;
    lastUpdateTime:f64 = 0.0;  // number of seconds since the last loop
    lastFrameTime:f64 = 0.0;   // number of seconds since the last frame

    uniform_sampler := gl.GetUniformLocation(shader.program_ID, "ourTexture")
    use_shader(&shader)
    gl.Uniform1i(uniform_sampler,0);

    for !glfw.WindowShouldClose(mainWindow)
    {
        now:f64 = glfw.GetTime();
        deltaTime:f64 = now - lastUpdateTime;

        glfw.PollEvents()
        
        // This if-statement only executes once every 60th of a second
        if ((now - lastFrameTime) >= fpsLimit)
        {
            gl.ClearColor(255, 255, 255, 255)
            gl.Clear(gl.COLOR_BUFFER_BIT)
            
            // draw your frame here
           
            use_shader(&shader)
            gl.BindTexture(gl.TEXTURE_2D, texID)
            update_shader_vec4(&shader, "time", auto_cast now)
            
            gl.BindVertexArray(vao)
            gl.DrawElements(gl.TRIANGLES, len(vertices), gl.UNSIGNED_INT, nil)
            glfw.SwapBuffers(mainWindow)
            gl.BindVertexArray(0)
            // only set lastFrameTime when you actually draw something
            lastFrameTime = now;
        }

        // set lastUpdateTime every iteration
        lastUpdateTime = now;
       
    }

}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	// Exit program on escape pressed
	// if key == glfw.KEY_ESCAPE {
	// 	running = false
	// }
    context = runtime.default_context()

	fmt.println("key pressed -> ", key)
    if(key == glfw.KEY_SPACE && action == glfw.PRESS){
        if(is_wireframe){
            gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
        }else{
            gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
        }
        is_wireframe = !is_wireframe
    }  
    
    
}

window_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int)
{
    gl.Viewport(0, 0, width, height)
    context = runtime.default_context();
    fmt.println("Resizing screen: Width:", width, " Height: ",height)
}