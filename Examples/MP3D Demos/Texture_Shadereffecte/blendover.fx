//-----------------------------------------------------------------------------
//           Name: effect.fx
//         Author: Kevin Harris
//  Last Modified: 12/14/02
//    Description: This effect is very simple. It defines a simple technique 
//                 called "TwoPassTextureBlend". As the name indicates, it 
//                 defines two separate rendering passes, called "Pass0" and 
//                 "Pass1", which basically blend two textures together. The 
//                 actual blend operation is a generic addition of texel data 
//                 in the frame buffer. It's nothing Earth shattering, but I 
//                 think it gets the point across.
//-----------------------------------------------------------------------------

texture TextureA;
texture TextureB;

technique TwoPassTextureBlend
{
    pass Pass0
    {
		//
		// For the first pass, set everything up for regular
		// texture mapping.
		//

        AlphaBlendEnable = False;

        Texture[0] = <TextureA>;

        ColorOp[0]   = SelectArg1;
        ColorArg1[0] = Texture;

        ColorOp[1]   = Disable;
    }

    pass Pass1
    {
		//
		// For the second pass, set everything up for regular
		// texture mapping again, but turn on some blending so 
		// we can blend the frame buffer's current contents with 
		// what's generated by our second rendering pass.
		//

        AlphaBlendEnable = True;
        SrcBlend  = One;
        DestBlend = One;

        Texture[0] = <TextureB>;

        ColorOp[0]   = SelectArg1;
        ColorArg1[0] = Texture;

        ColorOp[1]   = Disable;
    }
}



