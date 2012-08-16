attribute vec4 position;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;

uniform vec4 color;


void main()
{
    
    colorVarying = color;
    
    gl_Position = modelViewProjectionMatrix * position;
}
