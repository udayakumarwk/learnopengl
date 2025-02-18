package main


import gl "vendor:OpenGL"
import "base:runtime"
import glfw "vendor:glfw"
import c "core:c"
import "core:fmt"
import stbi "vendor:stb/image"
import glm "core:math/linalg/glsl"
import engine "engine"

firstMouse:=true
lastX: f64= f64(engine.MAIN_WINDOW_WIDTH)/2
lastY: f64= f64(engine.MAIN_WINDOW_HEIGHT)/2
yaw := -90.0;
pitch:=0.0

keys:engine.Keys


is_wireframe := false

main :: proc()
{

    engine.init_engine()
    defer engine.terminate_engine()
    
    // engine.SetWindowSizeCallback(engine.mainWindow, window_size_callback)
    engine.window_size_callback(window_size_callback_o)
    engine.SetKeyCallback(engine.mainWindow, key_callback)
    engine.SetMouseCallback(engine.mainWindow, window_mouse_callback)
    engine.SetScrollCallback(engine.mainWindow, scroll_callback)

    shader := engine.create_shader("shader/vertex.glsl", "shader/fragment.glsl")
    // shader := engine.load_default_shaders()

    // triangle:= [?]f32{
    //     // positions          // colors           // texture coords
    //     0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0, // top right
    //     0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0, // bottom right
    //    -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0, // bottom left
    //    -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0  // top left 
         
    // }

    triangle:= [?] f32 {
        -0.5, -0.5, -0.5,  0.0, 0.0,
         0.5, -0.5, -0.5,  1.0, 0.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5,  0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 0.0,
    
        -0.5, -0.5,  0.5,  0.0, 0.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
         0.5,  0.5 ,  0.5 ,  1.0 , 1.0 ,
         0.5 ,  0.5 ,  0.5 ,  1.0 , 1.0 ,
        -0.5 ,  0.5 ,  0.5 ,  0.0 , 1.0 ,
        -0.5 , -0.5 ,  0.5 ,  0.0 , 0.0 ,
    
        -0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
        -0.5 ,  0.5 , -0.5 ,  1.0 , 1.0 ,
        -0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
        -0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
        -0.5 , -0.5 ,  0.5 ,  0.0 , 0.0 ,
        -0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
    
         0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
         0.5 ,  0.5 , -0.5 ,  1.0 , 1.0 ,
         0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
         0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
         0.5 , -0.5 ,  0.5 ,  0.0 , 0.0 ,
         0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
    
        -0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
         0.5 , -0.5 , -0.5 ,  1.0 , 1.0 ,
         0.5 , -0.5 ,  0.5 ,  1.0 , 0.0 ,
         0.5 , -0.5 ,  0.5 ,  1.0 , 0.0 ,
        -0.5 , -0.5 ,  0.5 ,  0.0 , 0.0 ,
        -0.5 , -0.5 , -0.5 ,  0.0 , 1.0 ,
    
        -0.5 ,  0.5 , -0.5 ,  0.0 , 1.0 ,
         0.5 ,  0.5 , -0.5 ,  1.0 , 1.0 ,
         0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
         0.5 ,  0.5 ,  0.5 ,  1.0 , 0.0 ,
        -0.5 ,  0.5 ,  0.5 ,  0.0 , 0.0 ,
        -0.5 ,  0.5 , -0.5 ,  0.0 , 1.0 
    };

    vertices:= [?]u32{
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    }

    cubePositions := [?]glm.vec3 {
        {0.0,  0.0,  0.0},
         {2.0,  5.0, -15.0},
         {-1.5, -2.2, -2.5},
         {-3.8, -2.0, -12.3},
         {2.4, -0.4, -3.5},
        {-1.7,  3.0, -7.5},
         {1.3, -2.0, -2.5},
         {1.5,  2.0, -2.5},
         {1.5,  0.2, -1.5},
        {-1.3,  1.0, -1.5}
    };

   
    cube := engine.create_model(triangle[:],vertices[:])

    wall_tex := engine.load_texture("assets/textures/rock.png")
    fmt.println("wall_tex width =", wall_tex.img_width, " height=", wall_tex.img_height)
    
    
    fpsLimit :: 1.0 / 60.0;
    lastUpdateTime:f64 = 0.0;  // number of seconds since the last loop
    lastFrameTime:f64 = 0.0;   // number of seconds since the last frame

    engine.init_camera_3d()
    engine.use_shader(&shader)
    engine.update_shader_uniform1i(&shader,"ourTexture",0)
    //engine.update_shader_mat4(&shader,"model", &model_mat)
    //engine.update_shader_mat4(&shader,"view",&view_mat)
    //engine.update_shader_mat4(&shader,"projection",&proj_mat)
    
    
    for !engine.should_stop_running()
    {
        now:f64 = glfw.GetTime();
        engine.deltaTime = now - lastUpdateTime;

        glfw.PollEvents()
        
        // This if-statement only executes once every 60th of a second
        if ((now - lastFrameTime) >= fpsLimit)
        {
           
            updateInputs()
            gl.ClearColor(255, 255, 255, 255)
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
            // draw your frame here
            engine.use_shader(&shader)
            gl.ActiveTexture(gl.TEXTURE0)
            gl.BindTexture(gl.TEXTURE_2D, wall_tex.texID)
            engine.update_shader_vec4(&shader, "time", auto_cast now)
            //engine.update_shader_mat4(&shader,"model", &model_mat)
            engine.update_camera_3d()
            engine.update_shader_mat4(&shader,"view",&engine.view_mat)
            engine.update_shader_mat4(&shader,"projection",&engine.proj_mat)

            engine.bind_model(&cube)
            
                // calculate the model matrix for each object and pass it to shader before drawing
                engine.model_mat = 1.0
                engine.model_mat = engine.model_mat * glm.mat4Translate(cubePositions[0]);
                angle :f32= 20.0 * f32(0+1) * f32(now);
                //engine.model_mat = engine.model_mat * glm.mat4Rotate({1.0, 0.3, 0.5},glm.radians_f32(angle));
                engine.update_shader_mat4(&shader,"model", &engine.model_mat);
    
                gl.DrawArrays(gl.TRIANGLES, 0, 36);
            
            //gl.DrawElements(gl.TRIANGLES, len(vertices), gl.UNSIGNED_INT, nil)
            //gl.DrawArrays(gl.TRIANGLES, 0, 36);
            engine.swap_buffers()
            engine.unbind_model()
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
    camera_speed := 200 * engine.deltaTime
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
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_W) == glfw.PRESS)
    {
       keys.w = true;
        
    } 
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_W) == glfw.RELEASE) 
    {
        keys.w = false;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_S) == glfw.PRESS)
    {
        keys.s = true;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_S) == glfw.RELEASE)
    {
        keys.s = false;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_A) == glfw.PRESS)
    {
        keys.a = true;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_A) == glfw.RELEASE)
    {
        keys.a = false;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_D) == glfw.PRESS)
    {
        keys.d = true;
    }
    if(glfw.GetKey(engine.mainWindow, glfw.KEY_D) == glfw.RELEASE)
    {
        keys.d = false;
    }
    
    
}

window_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int)
{
    gl.Viewport(0, 0, width, height)
    context = runtime.default_context();
    fmt.println("Resizing screen: Width:", width, " Height: ",height)
}

window_size_callback_o :: proc(window: glfw.WindowHandle, width, height:i32){
    // gl.Viewport(0, 0, width, height)
    fmt.println("Resizing screen: Width:", width, " Height: ",height)
}


window_mouse_callback :: proc "c" (window:glfw.WindowHandle, xpos:f64, ypos:f64)
{
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
  
    xoffset := xpos - lastX;
    yoffset := lastY - ypos; 
    lastX = xpos;
    lastY = ypos;

    sensitivity:= 0.1;
    xoffset *= sensitivity;
    yoffset *= sensitivity;

    yaw   += xoffset;
    pitch += yoffset;

    pitch = clamp(pitch,-89.0,89.0)
       
    direction:glm.vec3;
    direction.x = auto_cast (glm.cos(glm.radians(yaw)) * glm.cos(glm.radians(pitch)));
    direction.y = auto_cast glm.sin(glm.radians(pitch));
    direction.z = auto_cast (glm.sin(glm.radians(yaw)) * glm.cos(glm.radians(pitch)));
    engine.camera_front = glm.normalize(direction);
} 

scroll_callback :: proc "c"(window:glfw.WindowHandle, xoffset:f64, yoffset:f64)
{
    engine.fov -= yoffset;

    engine.fov = clamp(pitch,1.0,45.0)
    
        
}

updateInputs :: proc()
{
    camera_speed := 200 * engine.deltaTime


    if keys.w 
    {
        engine.camera_pos = engine.camera_pos + f32(camera_speed) * engine.camera_front
    }

    if keys.s
    {
        engine.camera_pos = engine.camera_pos - f32(camera_speed) * engine.camera_front
    }
    if keys.a
    {
        engine.camera_pos -= glm.normalize(glm.cross_vec3(engine.camera_front, engine.camera_up)) * f32(camera_speed);
    
    }
    if keys.d
    {
        engine.camera_pos += glm.normalize(glm.cross_vec3(engine.camera_front, engine.camera_up)) * f32(camera_speed);
    }
}