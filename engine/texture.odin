package engine

import stbi "vendor:stb/image"
import gl "vendor:OpenGL"
import "core:fmt"
import "core:strings"

Texture :: struct
{
    img_width, img_height, img_chan :i32,
    texID : u32,
    img_data : rawptr
}


load_texture :: proc(path:string) -> (texture:Texture)
{
    
    texture.img_data = stbi.load(strings.clone_to_cstring(path), &texture.img_width, &texture.img_height, &texture.img_chan, 0)

    gl.GenTextures(1, &texture.texID)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture.texID)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    if (texture.img_data!=nil)
    {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, texture.img_width, texture.img_height, 0, gl.RGBA, gl.UNSIGNED_BYTE, texture.img_data);
        gl.GenerateMipmap(gl.TEXTURE_2D);
    }
    else
    {
        fmt.println("Failed to load texture : ", path)
    }
    gl.BindTexture(gl.TEXTURE_2D, 0)
    stbi.image_free(texture.img_data)
    return texture
}

unload_texture :: proc(texture:Texture)
{
    stbi.image_free(texture.img_data)
}