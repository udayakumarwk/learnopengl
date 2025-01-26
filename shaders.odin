package main

import "core:os"
import "core:fmt"
import "core:strings"
import gl "vendor:OpenGL"
import "core:c"

Shader :: struct {
    program_ID:u32,
    vertex_shader:cstring,
    fragment_shader:cstring,
    isOk:bool,
    error:string
}

create_shader :: proc(vertex_path, fragmenT_path:string) -> (shader:Shader)
{
    vertex_glsl, ok := os.read_entire_file(vertex_path) 
    defer delete(vertex_glsl)
    if(!ok){
        fmt.println("Failed to read vertex file, path=",vertex_path)
        shader.error = "Failed to read vertex file"
        shader.isOk = false
        return shader;
    } 
    shader.vertex_shader =  strings.clone_to_cstring(string(vertex_glsl))

    fragment_glsl, frag_ok := os.read_entire_file(fragmenT_path)
    defer delete(fragment_glsl)
    if(!frag_ok){
        fmt.println("Failed to read fragment file, path=",fragmenT_path)
        shader.error = "Failed to read fragment file"
        shader.isOk = false
        return shader;
    }   
    shader.fragment_shader = strings.clone_to_cstring((string(fragment_glsl)))

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &shader.vertex_shader, nil)
    gl.CompileShader(vertex_shader)
    success:c.int;
    infoLog:= make([]byte,512)
    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
    if(success==0)
    {
        gl.GetShaderInfoLog(vertex_shader, auto_cast 512, nil , raw_data(infoLog));
        fmt.println("Compilation failed\n",string(infoLog))
        shader.error = string(infoLog)
        shader.isOk = false;
    }

    
    frag_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(frag_shader, 1, &shader.fragment_shader, nil)
    gl.CompileShader(frag_shader)
    infoLog = make([]byte,512)
    gl.GetShaderiv(frag_shader, gl.COMPILE_STATUS, &success)
    if(success==0)
    {
        gl.GetShaderInfoLog(frag_shader, auto_cast 512, nil , raw_data(infoLog));
        fmt.println("Compilation failed\n",string(infoLog))
        shader.error = string(infoLog)
        shader.isOk = false;
    }

    shader.program_ID = gl.CreateProgram()
    gl.AttachShader(shader.program_ID, vertex_shader)
    gl.AttachShader(shader.program_ID, frag_shader)
    gl.LinkProgram(shader.program_ID)

    gl.GetProgramiv(shader.program_ID, gl.LINK_STATUS, &success)
    if(success==0) {
        gl.GetProgramInfoLog(shader.program_ID, 512, nil, raw_data(infoLog))
        fmt.println("Compilation failed\n",string(infoLog))
    }

    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(frag_shader)

    shader.isOk = true;
    return shader
}

use_shader :: proc(shader:^Shader)
{
    if(!shader.isOk)
    {
        return
    }
    gl.UseProgram(shader.program_ID)
}

update_shader_vec4 :: proc(shader:^Shader, location:cstring, f:f32)
{
    if(!shader.isOk)
    {
        return
    }
    loc := gl.GetUniformLocation(shader.program_ID, location)
    gl.Uniform1f(loc, f)
}


DEFAULT_VERTEX_SHADER :cstring= `
#version 330 core
layout (location = 0) in vec3 aPos;
out vec4 outcolor;
uniform float time;
void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    outcolor = vec4(clamp(sin(time*aPos),0.0f,1.0f),1.0);
}`

DEFAULT_FRAGMENT_SHADER :cstring= `#version 330 core
out vec4 FragColor;
in vec4 outcolor;

void main()
{
    FragColor = outcolor;
} `