///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
// NOTE: You can write several shaders in the same file if you want as
// long as you embrace them within an #ifdef block (as you can see above).
// The third parameter of the LoadProgram function in engine.cpp allows
// chosing the shader you want to load by name.

#ifdef TEXTURED_GEOMETRY

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
	vTexCoord = aTexCoord;
	gl_Position = vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

in vec2 vTexCoord;

uniform sampler2D uTexture;

layout(location = 0) out vec4 oColor;

void main()
{
	oColor = texture(uTexture, vTexCoord);
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef SHOW_TEXTURED_MESH

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec3 aNormal;
layout(location=2) in vec2 aTexCoord;

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(binding = 1, std140) uniform LocalParams
{
	mat4 uWorldMatrix;
	mat4 uWorldViewProjectionMatrix;
};

out vec2 vTexCoord;
out vec3 vPosition; 
out vec3 vNormal; 
out vec3 vViewDir;

void main()
{
	vTexCoord = aTexCoord;
	vPosition = vec3(uWorldMatrix * vec4(aPosition, 1.0));
	vNormal = vec3(uWorldMatrix * vec4(aNormal, 0.0));
	vViewDir = uCameraPosition - vPosition;
	gl_Position = uWorldViewProjectionMatrix * vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

in vec2 vTexCoord;
in vec3 vPosition; 
in vec3 vNormal; 
in vec3 uViewDir; 

uniform sampler2D uTexture;

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(location = 0) out vec4 oColor;
layout(location = 1) out vec4 oNormals;
layout(location = 2) out vec4 oAlbedo;
layout(location = 3) out vec4 oDepth;
layout(location = 4) out vec4 oPosition;

float near = 0.1; 
float far  = 100.0; 
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));	
}

void main()
{
	vec4 albedo = texture(uTexture, vTexCoord);

	// Ambient lighting
    float ambientStrength = 0.5;
    vec3 ambientColor = albedo.xyz * ambientStrength;

	// Diffuse lighting
	vec3 diffuseColor;

	// Specular lighting
    vec3 specular = vec3(1.0); 
	vec3 specularColor;

    vec3 norm = normalize(vNormal); 
	vec3 lightDir = normalize(-uViewDir.xyz); 

	for(int i = 0; i < uLightCount; ++i)
	{
	    float attenuation = 1.0f;
		
		if(uLight[i].type == 1) // Point Light
		{
			float dist = length(uLight[i].position - vPosition);
			float linear = 0.09;
			float quadratic = 0.032;
			attenuation = 1.0 / (1.0 + linear * dist + quadratic * dist * dist);
		}

	    vec3 dir = normalize(uLight[i].direction - uViewDir.xyz); 
	    
	    // Diffuse
	    float diff = max(0.0, dot(norm, dir));
	    diffuseColor += diff * uLight[i].color * albedo.xyz * attenuation;

		// Reflection
	    vec3 reflection = reflect(-dir, norm);
	    
	    // Specular
	    float spec = pow(max(dot(reflection, lightDir), 0.0), 32);
	    specularColor += spec * uLight[i].color * specular * attenuation;
	}

	oColor = vec4(ambientColor + diffuseColor + specularColor, 1.0);

    oNormals = vec4(normalize(vNormal), 1.0); 
	
	oAlbedo = texture(uTexture, vTexCoord);

	float depth = LinearizeDepth(gl_FragCoord.z) / far;
	oDepth = vec4(vec3(depth), 1.0);

	oPosition = vec4(vec3(vPosition), 1.0);
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef GEOMETRY_PASS

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec3 aNormal;
layout(location=2) in vec2 aTexCoord;

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(binding = 1, std140) uniform LocalParams
{
	mat4 uWorldMatrix;
	mat4 uWorldViewProjectionMatrix;
};

out vec2 vTexCoord;
out vec3 vPosition;
out vec3 vNormal; 
out vec3 vViewDir; 

void main()
{
	vTexCoord = aTexCoord;
	vPosition = vec3(uWorldMatrix * vec4(aPosition, 1.0));
	vNormal = vec3(uWorldMatrix * vec4(aNormal, 0.0));
	vViewDir = uCameraPosition - vPosition;
	gl_Position = uWorldViewProjectionMatrix * vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////


struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

in vec2 vTexCoord;
in vec3 vPosition;
in vec3 vNormal;
in vec3 uViewDir; 

uniform sampler2D uTexture;
uniform int noTexture;

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(location = 0) out vec4 oColor;
layout(location = 1) out vec4 oNormals;
layout(location = 2) out vec4 oAlbedo;
layout(location = 3) out vec4 oDepth;
layout(location = 4) out vec4 oPosition;

float near = 0.1; 
float far  = 100.0; 
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));	
}

void main()
{
    oNormals = vec4(normalize(vNormal), 1.0); 
	oAlbedo = texture(uTexture, vTexCoord);

	if(noTexture == 1.0)
	{
		oAlbedo = vec4(0.5);
	}

	float depth = LinearizeDepth(gl_FragCoord.z) / far; 
	oDepth = vec4(vec3(depth), 1.0);

	oPosition = vec4(vec3(vPosition), 1.0);
}

#endif
#endif


///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef SHADING_PASS

#if defined(VERTEX) ///////////////////////////////////////////////////


layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(binding = 1, std140) uniform LocalParams
{
	mat4 uWorldMatrix;
	mat4 uWorldViewProjectionMatrix;
};

out vec2 vTexCoord;
out vec3 ViewPos; 

void main()
{
	vTexCoord = aTexCoord;
	ViewPos = uCameraPosition;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

in vec2 vTexCoord;
in vec3 ViewPos; 

layout(binding = 0, std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

uniform sampler2D oNormals;
uniform sampler2D oAlbedo;
uniform sampler2D oDepth;
uniform sampler2D oPosition;
uniform sampler2D oOcclusion;

layout(location = 0) out vec4 oColor;

void main()
{
	vec3 vPosition = texture(oPosition, vTexCoord).xyz;
	vec3 Normal = texture(oNormals, vTexCoord).xyz;
	vec3 albedo = texture(oAlbedo, vTexCoord).xyz;
	vec3 viewDir = normalize(ViewPos - vPosition);
	float occlusion = texture(oOcclusion, vTexCoord).x;

	// Ambient lighting
    float ambientStrength = 0.5;
    vec3 ambientColor;

	// Diffuse lighting
	vec3 diffuseColor;

	// Specular lighting
	vec3 specularColor;

    vec3 norm = normalize(Normal); 
	vec3 lightDir = normalize(-viewDir.xyz);

	ambientColor = albedo * ambientStrength * occlusion;

	for(int i = 0; i < uLightCount; ++i)
	{
	    float attenuation = 1.0f;
		
		if(uLight[i].type == 1) // Point Light
		{
			float dist = length(uLight[i].position - vPosition);
			float linear = 0.09;
			float quadratic = 0.032;
			attenuation = 1.0 / (1.0 + linear * dist + quadratic * dist * dist);
		}
	        
	    vec3 dir = normalize(uLight[i].direction - viewDir.xyz);
	    
	    // Diffuse
	    float diff = max(0.0, dot(norm, dir))*0.5;
	    diffuseColor += diff * uLight[i].color * albedo * attenuation;
	    
		vec3 reflection = reflect(-dir, norm);

	    // Specular
	    float spec = pow(max(dot(reflection, lightDir), 0.0), 32);
	    specularColor += spec * uLight[i].color * attenuation;
	}
	
    oColor = vec4(ambientColor + diffuseColor + specularColor, 1.0);
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef BRIGHTEST_PIXELS

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
	vTexCoord = aTexCoord;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

uniform sampler2D colorTexture;
uniform float threshold;
in vec2 vTexCoord;
out vec4 outColor;

void main()
{
    vec4 color = texture(colorTexture, vTexCoord);
	float intensity = dot(color.rgb, vec3(0.21, 0.71, 0.08));
	float threshold1 = threshold;
	float threshold2 = threshold + 0.1;
	outColor = color * smoothstep(threshold1, threshold2, intensity);
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef BLUR

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
	vTexCoord = aTexCoord;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

uniform sampler2D colorMap;
uniform vec2 direction;
uniform int inputLod;
uniform int kernelRadius;

in vec2 vTexCoord;
out vec4 outColor;

void main()
{
    vec2 texSize = textureSize(colorMap, inputLod);
	vec2 texelSize = 1.0/texSize;
	vec2 margin1 = texelSize * 0.5;
	vec2 margin2 = vec2(1.0) - margin1;

	outColor = vec4(0.0);

	vec2 directionFragCoord = gl_FragCoord.xy * direction;
	int coord = int(directionFragCoord.x + directionFragCoord.y);
	vec2 directionTexSize = texSize * direction;
	int size = int(directionTexSize.x + directionTexSize.y);
	int kernelBegin = -min(kernelRadius, coord);
	int kernelEnd = min(kernelRadius, size - coord);
	float weight = 0.0;

	for(int i = kernelBegin; i <= kernelEnd; ++i)
	{
		float currentWeight = smoothstep(float(kernelRadius), 0.0, float(abs(i)));
		vec2 finalTexCoords = vTexCoord + i * direction * texelSize;
	    finalTexCoords = clamp(finalTexCoords, margin1, margin2);
		outColor += textureLod(colorMap, finalTexCoords, inputLod) * currentWeight;
		weight += currentWeight;		
	}

	outColor = outColor / weight;
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef BLOOM

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
	vTexCoord = aTexCoord;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

uniform sampler2D colorMap;
uniform int maxLod;
uniform int lodI0;
uniform int lodI1;
uniform int lodI2;
uniform int lodI3;
uniform int lodI4;


in vec2 vTexCoord;
out vec4 outColor;

void main()
{  
	outColor = vec4(0.0);

	for(int lod = 0; lod < maxLod; ++lod)
	{
		if(lod == 0) 
			outColor += textureLod(colorMap, vTexCoord, float(lod)) * lodI0;	
		
		else if (lod == 1)
			outColor += textureLod(colorMap, vTexCoord, float(lod)) * lodI1;
				
		else if (lod == 2)
			outColor += textureLod(colorMap, vTexCoord, float(lod)) * lodI2;
		
		else if (lod == 3)
			outColor += textureLod(colorMap, vTexCoord, float(lod)) * lodI3;
		
		else if (lod == 4)
			outColor += textureLod(colorMap, vTexCoord, float(lod)) * lodI4;
	}

	outColor.a = 1.0;
}

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef SSAO

#if defined(VERTEX)

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
    vTexCoord = aTexCoord;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) 

uniform sampler2D gPosition;
uniform sampler2D gNormal;
uniform sampler2D texNoise;

uniform float SSAO;
uniform float Radius;
uniform float Bias;

uniform vec3 samples[64];
uniform mat4 projection;

in vec2 vTexCoord;

layout(location = 5) out vec4 oOcclusion;

int kernelSize = 64;
float radius = Radius;
float bias = Bias;

const vec2 noiseScale = vec2(800.0/4.0, 700.0/4.0);

void main()
{
    
    vec3 fragPos   = texture(gPosition, vTexCoord).xyz;
    vec3 normal    = texture(gNormal, vTexCoord).rgb;
    vec3 randomVec = texture(texNoise, vTexCoord * noiseScale).xyz; 

    vec3 tangent   = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN       = mat3(tangent, bitangent, normal);  

    float occlusion = 0;

    for(int i = 0; i < kernelSize; ++i)
    {
        vec3 samplePos = TBN * samples[i];
        samplePos = fragPos + samplePos * radius; 

        vec4 offset = vec4(samplePos, 1.0);
        offset      = projection * offset;    
        offset.xyz /= offset.w;               
        offset.xyz  = offset.xyz * 0.5 + 0.5;   

        float sampleDepth = texture(gPosition, offset.xy).z; 

        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += (sampleDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;
    }

    occlusion = 1.0 - (occlusion / kernelSize);  
    oOcclusion = vec4(vec3(occlusion), 1.0);

#endif
#endif

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
#ifdef SSAO_BLUR

#if defined(VERTEX)

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoord;

out vec2 vTexCoord;

void main()
{
    vTexCoord = aTexCoord;
	gl_Position =  vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) 

uniform sampler2D ssaoInput;

in vec2 vTexCoord;

layout(location = 5) out vec4 oOcclusion;

void main()
{
    vec2 texelSize = 1.0 / vec2(textureSize(ssaoInput, 0));
    float result = 0.0;
    for (int x = -2; x < 2; ++x) 
    {
        for (int y = -2; y < 2; ++y) 
        {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            result += texture(ssaoInput, TexCoords + offset).r;
        }
    }
    result /= (4.0 * 4.0);
    oOcclusion = vec4(vec3(result), 1.0);
}

#endif
#endif