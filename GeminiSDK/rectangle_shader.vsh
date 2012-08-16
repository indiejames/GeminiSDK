attribute vec4 position;
attribute vec4 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;



void main()
{
    
    colorVarying = color;
    
    gl_Position = modelViewProjectionMatrix * position;
}
