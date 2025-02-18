package engine

import gl "vendor:OpenGL"
import "core:fmt"
Model :: struct {
    vbo, vao, eio:u32,
    vertices:[]f32,
    indeices:[]u32
}

create_model :: proc(vertices:[]f32, indecies:[]u32) -> Model
{
    model:Model
    if(len(vertices) <=0)
    {
        fmt.println("Failed to create model:: Vertices are empty")
        return model
    }
    model.vertices = vertices
    gl.GenVertexArrays(1,&model.vao)
    gl.BindVertexArray(model.vao)

    
    gl.GenBuffers(1, &model.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER,model.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(model.vertices)*size_of(model.vertices[0]), raw_data(model.vertices[:]), gl.STATIC_DRAW)
    
    if(len(indecies) > 0){
        model.indeices = indecies
        gl.GenBuffers(1, &model.eio)
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER,model.eio)
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(u32) * len(model.vertices), raw_data(model.vertices[:]),gl.STATIC_DRAW)
    
    }
    //position attribute
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0); 
    //texture attribute
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)

    gl.BindVertexArray(0)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    append(&vbo_list, model.vbo)
    append(&vao_list, model.vao)
    append(&eio_list, model.eio)
    
    return model
}

bind_model :: proc(model:^Model) 
{
    gl.BindVertexArray(model.vao)
}

unbind_model :: proc()
{
    gl.BindVertexArray(0)
}