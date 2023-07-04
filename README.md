# Godot VAT3

![vatPreview](https://github.com/G4ND44/Godot_VAT3/assets/30861241/5de1ab79-0c87-4733-b7e6-709cd4738f7f)

__Godot Plugin for Houdini Vertex Animation Textures__


This is port of Houdini VAT3 for Godot, based on Unity And Unreal versions.

It has two parts: modified Houdini Plugin and Godot Shaders

---------------------------------------------
Godot Install
------------------
To use it in your project you just need to copy VAT3_GodotEngine folder

![godot windows opt tools 64_sgaY8XgMUB](https://github.com/G4ND44/Godot_VAT3/assets/30861241/16ad69de-52ee-43da-89d7-9fd11d186031)


-------------------------------------
HDA instalation
------------------

Copy driver_labs.vertex_animation_textures.3.1.hdalc to yours HDA folder

![explorer_voT4TFylKj](https://github.com/G4ND44/Godot_VAT3/assets/30861241/0bed85d7-86b9-4a34-bf23-44984bb5c182)

Usage in shader
===========
First you need to declare type and include library

![godot windows opt tools 64_oQiP9u25D3](https://github.com/G4ND44/Godot_VAT3/assets/30861241/9ca82e32-45c2-4966-82b4-7281d381c80c)

Available modes:

_VAT3MODE_SOFTBODY_

_VAT3MODE_RIGIDBODY_

_VAT3MODE_DYNAMICMESH_

_VAT3MODE_PARTICLES_

Then you need to grab the material inputs and apply them on the shader

![godot windows opt tools 64_Lss9aTwnsp](https://github.com/G4ND44/Godot_VAT3/assets/30861241/2573d407-992a-42a2-b1cf-36bc409ff759)

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

![godot windows opt tools 64_7KKqIvvG1d](https://github.com/G4ND44/Godot_VAT3/assets/30861241/5cd5df21-63a4-4d4f-88b5-cbbae309ead2)
![godot windows opt tools 64_YFc6Ddp9yr](https://github.com/G4ND44/Godot_VAT3/assets/30861241/f24adb5e-48a3-48b4-b5ad-be90b7176bce)


When importing texture (HDR or LDR) disable any compresion 

![godot windows opt tools 64_6u06dBE1aJ](https://github.com/G4ND44/Godot_VAT3/assets/30861241/4d1b0105-a78e-47e1-86cc-193a817d4e65)


For convinience you can use vatSetUnifroms for loading data from JSON to material. Rest of setting on material is set up manually.
![godot windows opt tools 64_8d0pnigQUh](https://github.com/G4ND44/Godot_VAT3/assets/30861241/aa2a0979-3c07-44a4-b1b4-addf40bdd857)


Houdini VAT generation
----------------------

With modified version you have to change engine for Godot 

![hindie steam_KlZQ9TVTco](https://github.com/G4ND44/Godot_VAT3/assets/30861241/29ec35f1-95eb-4260-ad4e-aa51e5681fe7)

You will also need a JSON file 

![hindie steam_MV81fVp2mN](https://github.com/G4ND44/Godot_VAT3/assets/30861241/670d9494-ecb2-47a1-bddc-9c4521106613)


You need too change Include type to Decide Individually

![hindie steam_sef5K5t2Us](https://github.com/G4ND44/Godot_VAT3/assets/30861241/4f39bd39-3721-41fc-96e5-b821a50ea247)


When exporting, remember to change extension to gltf 
__It is important since only gltf have proper scale and supports 4 uv channels__

![hindie steam_b7n6T9Ks95](https://github.com/G4ND44/Godot_VAT3/assets/30861241/056d43cc-ce0c-498b-94c8-95174e934cf8)

It is also good pratice to have the frame count, since JSON does not receive this information

![hindie steam_1hCW0RYyCa](https://github.com/G4ND44/Godot_VAT3/assets/30861241/9fdbd279-5136-4117-a7e2-9bb8258416c4)

Big shoutout to Celyk for helping with the Quaterions formula, JSON loader, testing, and providing feedback
https://github.com/celyk
