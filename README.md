# Godot VAT3

Godot Plugin for Houdini Vertex Animation Textures

![vatPreview](https://github.com/G4ND44/Godot_VAT3/assets/30861241/f38f7587-666f-4ca7-8186-833d1b1b3c7b)

This is port of Houdini VAT3 for Godot, based on Unity And Unreal versions.

It has two parts: modified Houdini Plugin and Godot Shaders

---------------------------------------------
Godot Install
------------------
To use it in your project you just need to copy VAT3_GodotEngine folder

![godot windows opt tools 64_sgaY8XgMUB](https://github.com/G4ND44/Godot_VAT3/assets/30861241/0184d89c-d935-448c-9f32-33b6c4d55ca3)


-------------------------------------
HDA instalation
------------------

Copy driver_labs.vertex_animation_textures.3.1.hdalc to yours HDA folder

![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/86c6941d-2787-47ae-804e-f3b3893c7450)

Usage in shader
===========
First you need to declare type and include library

![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/d0c5de7f-b81c-4c3c-b712-96519200f300)

Available modes:

_VAT3MODE_SOFTBODY_

_VAT3MODE_RIGIDBODY_

_VAT3MODE_DYNAMICMESH_

_VAT3MODE_PARTICLES_

Then you need to grab the material inputs and apply them on the shader

![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/baaf1423-fd6f-40a9-b665-a33e814e370b)

_Vat3_Outputs_ struct provides some outputs, which then can be used futher in the shader. See examples

------------------

More avaible keywords:

_VAT_OUTPUT_FULL_ // gives some additional data for futher use in shader

_NO_VAT_NORMAL_ // disable normals calculations, usefull when used with no shading

_NO_VAT_TANGENT_ // disable tangent calculations, use it when you dont need tangent for normals

_VAT_USE_COMPRESSED_NORMALS_ // use normal from position texture alpha instead of rot textures

_NO_LERPING_ // disables all calculations and variables for interframe lerping

_VAT_LOAD_COL_TEX_ // load vertex color texture

_VAT_LOAD_SPARE_COL_TEX_ // load spare vertex color texture

_VAT_SMOOTH_TRAJECTORIES_ // smoothing rigid body trajectiores, use it when lerping is not enough

Loading data for shaders
----------------------
For meshes disable any lod, tangent and uvs generation

![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/e4ded355-46a4-4e07-9a62-5f48c9a3d127)
![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/2998525f-cb73-4f3b-955f-4f4f883d1bb8)

When importing texture (HDR or LDR) disable any compresion 

![godot windows opt tools 64_6u06dBE1aJ](https://github.com/G4ND44/Godot_VAT3/assets/30861241/4fb9cd60-2291-4fd1-a098-2e197f9c1126)

For convinience you can use vatSetUnifroms for loading data from JSON to material. Rest of setting on material is set up manually.
![obraz](https://github.com/G4ND44/Godot_VAT3/assets/30861241/1667167a-8ab1-4a70-9d0b-dfef3ea2af4a)


Houdini VAT generation
----------------------

With modified version you have to change engine for Godot 

![hindie steam_KlZQ9TVTco](https://github.com/G4ND44/Godot_VAT3/assets/30861241/ed6082f5-6d5c-402b-b7bf-091c6248b090)

You will also need a JSON file 

![hindie steam_MV81fVp2mN](https://github.com/G4ND44/Godot_VAT3/assets/30861241/cf444d83-5c96-445d-b300-06980dd60692)

You need too change Include type to Decide Individually

![hindie steam_sef5K5t2Us](https://github.com/G4ND44/Godot_VAT3/assets/30861241/6db1dd41-7e13-4056-b4a4-17fb23474d9c)

When exporting, remember to change extension to gltf 
__It is important since only gltf have proper scale and supports 4 uv channels__

![hindie steam_b7n6T9Ks95](https://github.com/G4ND44/Godot_VAT3/assets/30861241/18ffe575-6559-42c5-b8ee-fb201275d35f)

It is also good pratice to have the frame count, since JSON does not receive this information

![hindie steam_1hCW0RYyCa](https://github.com/G4ND44/Godot_VAT3/assets/30861241/5cf90a6d-25f9-45ab-be96-c6750feca3d8)

Big shoutout to Celyk for helping with the Quaterions formula, JSON loader, testing, and providing feedback
https://github.com/celyk
