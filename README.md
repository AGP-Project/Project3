# Project3

This is the final delivery of the Advanced Graphics Programming subject and this README contains all its documentation.

## Made by:
[Òscar Faura](https://github.com/ofaura)

[Dídac Romero](https://github.com/DidacRomero)

## Instructions of use

**Camera Movement:** W, A, S, D, E, Q

**Camera rotation:** (Mouse) Left click & drag

---

Aside from the camera movement, we have an Imgui tab to control different aspects of the model viewer and to see information of OpenGL and our graphics context.

First, we have a text area were you can see the current FPS and information regarding the OpenGL version, renderer etc.

![Info](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Information.JPG "Information")

---

After that, we have a set of boxes in which we can set the movement speed, FOV (Field of View), nearplane, farplane and camera position.

![Camera](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Camera_Imgui.JPG "Camera")

---

After that we have a set of sections to use Bloom and SSAO but those will be covered further in the documentation. After these we have a Render Mode combobox to change the rendering mode. By clicking on the small arrow you can switch between these modes:

* Deferred Render
* Forward Render
* Albedo
* Depth
* Normals
* Position

![Mode](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Render_Mode_Imgui.JPG "Render Mode")

---

Finally, we have a window with all the GLSL extensions listed, and the list can be navigated using the small bar on the right.

![Extensions](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/GLSL_Extensions.JPG "Extensions") 

## Advanced Techniques
For this delivery we implemented Bloom and SSAO (Screen Space Ambient Oclusion).

### Bloom

![Bloom](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Bloom_Complete_Gif.gif "Bloom gif") 

As you can see, we implemented Bloom to the model viewer. Here we can see 2 images of the before and after applying this technique.

| Bloom Off        | Bloom ON           |
| ------------- |:-------------:|
| ![Without Bloom](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/No_Bloom_Defferred.JPG "Without Bloom")      | ![With Bloom](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Bloom_Defferred.JPG "With Bloom") |



To enable/disable Bloom you only need to click on the checkbox called *renderBloom*. You can also change the Threshold by clicking  on the threshold text box 
& typing the desired number.

You can also change the Kernel Radius and the intensity of each level of detail by pressing the - or + buttons next to each label!

![Bloom](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/Bloom_Imgui.JPG "Extensions") 

You can find the code for bloom under **line 515** of the **shaders.glsl** file!

--

### Screen space ambient occlusion (SSAO)

Sadly with screen space ambient occlusion we seem to have an issue. As you can see in the gif, there's no change whenever SSAO is applied to the render.

![SSAO Not working](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/SSAO_Not_Working.gif "SSAO Not working") 

This is also certain when looking at the before/after pictures.
| SSAO Off        | SSAO ON           |
| ------------- |:-------------:|
| ![SSAO Off](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/SSAO_Off.JPG "SSAO OFF")      | ![SSAO On](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/SSAO_On.JPG "SSAO ON")	|


To manipulate the properties of SSAO you can check or uncheck the SSAO checkbox and then use the slider buttons Radius & Bias. In these boxes
you can either drag your mouse while clicking, or double click and type the desired number you want.

![SSAO](https://raw.githubusercontent.com/AGP-Project/Project3/main/Documentation_Images/SSAO_Imgui.JPG "SSAO")

The code for the SSAO Technique can be found under **line 575**  of the **shaders.glsl** file!






