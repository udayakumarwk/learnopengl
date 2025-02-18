package engine

import glm "core:math/linalg/glsl"

camera_pos   :glm.vec3   = {0.0,0.0,3.0}
camera_front :glm.vec3   = {0.0,0.0,-1.0}
camera_up    :glm.vec3   = {0.0,1.0,0.0}

fov:=45.0

//matrix
model_mat:glm.mat4 = 1
view_mat: glm.mat4 = 1
proj_mat: glm.mat4 = 1

init_camera_3d :: proc()
{
    model_mat = model_mat * glm.mat4Rotate({1.0, 0.0, 0.0}, glm.radians_f32(0.1))

    //view_mat = view_mat * glm.mat4Translate({0.0, 0.0, -5}) 

    proj_mat = glm.mat4Perspective(auto_cast fov, auto_cast (MAIN_WINDOW_WIDTH/MAIN_WINDOW_HEIGHT), 0.1, 100.0)

}

update_camera_3d :: proc()
{
    model_mat = model_mat * glm.mat4Rotate({0.5, 0.5, 0}, glm.radians_f32(1.0))
    view_mat = glm.mat4LookAt(camera_pos, camera_pos + camera_front,camera_up)
    proj_mat = glm.mat4Perspective(auto_cast fov, auto_cast (MAIN_WINDOW_WIDTH/MAIN_WINDOW_HEIGHT), 0.1, 100.0)
   
}