//fragment shader

#version 330 core

out vec4 FragColor;

in vec4 outcolor;
in vec2 texCords;

uniform sampler2D ourTexture;

void main()
{
    FragColor = texture(ourTexture,texCords);
}