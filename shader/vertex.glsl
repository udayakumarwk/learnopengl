//vertex shader
#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 atexCords;

out vec4 outcolor;
out vec2 texCords;
uniform float time;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    outcolor = vec4(clamp(sin(time*aPos),0.0f,1.0f),1.0);
    texCords = atexCords;
}