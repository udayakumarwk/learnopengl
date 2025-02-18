//vertex shader
#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 atexCords;

out vec4 outcolor;
out vec2 texCords;
out float time_;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float time;


void main()
{
    gl_Position = projection * view * model * vec4(aPos.x, aPos.y, aPos.z, 1.0);
    outcolor = vec4(clamp(aPos,0.0f,1.0f),1.0);
    texCords = atexCords;
    time_ = time;
}