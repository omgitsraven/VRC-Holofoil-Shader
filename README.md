# VRC-Holofoil-Shader

This is RavenWorks's holofoil shader, as seen in Shaderfes 2021.  You can view/download just the shader, or a .unitypackage file which contains a simple example of how to use it.

It takes two textures: an ordinary "color texture", and then a grayscale "mask texture" which says how much each region should shift its colors as the player moves their head. (So you can have a logo that doesn't change color, and a background that does, and some sparkles that do even more, for instance.)

Because of how the effect works, you can't really combine multiple lights on this shader... I considered having it use the closest light, but that would make it snap oddly if it moved from one light to another, so instead you can just hard-code a light direction to use.  This is how it worked in the ShaderFes world; I think this will suit what people probably want to do with it.  (Also, note that whatever direction you specify, it'll also act like there's a second light on the opposite side, just to cut down on the odds of someone seeing it from an angle that isn't "shiny".)

Note that if the edge of a mask region is over something besides black, you'll see a very tight rainbow around its edge, as the bilinear filtering 'gradient' makes the hue shift catch up to wherever it should be on the other color...  It looks kind of neat though, so whatever.

I really want to specify: I like how this looks, but I honestly made it just for a single situation, and there's lots of reasons why it doesn't generalize well, so I won't really be doing support for it or anything.  I wasn't planning on distributing it, but people kept asking, so here it is.  It's really nothing like real holofoil though (maybe someday I'll make an accurate one, though I feel like that'll probably be less fun to look at than this one is).
