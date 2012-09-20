varying lowp vec4 colorVarying;
varying lowp vec2 texCoordVarying;

uniform sampler2D texture;

void main()
{
    lowp vec4 textureColor = texture2D(texture, texCoordVarying);

    gl_FragColor = colorVarying * textureColor;
    /*gl_FragColor = vec4(1.0,1.0,1.0,1.0);*/
   
}