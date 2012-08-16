attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 colorVarying;
varying lowp vec2 texCoordVarying;

uniform mat4 modelViewProjectionMatrix;



void main()
{
    colorVarying = color;
    texCoordVarying = texCoord;
    gl_Position = modelViewProjectionMatrix * position;
}
