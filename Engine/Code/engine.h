//
// engine.h: This file contains the types and functions relative to the engine.
//

#pragma once

#include "platform.h"
#include <glad/glad.h>

#include <random>

#define BINDING(b) b

typedef glm::vec2  vec2;
typedef glm::vec3  vec3;
typedef glm::vec4  vec4;
typedef glm::ivec2 ivec2;
typedef glm::ivec3 ivec3;
typedef glm::ivec4 ivec4;

class EditorConsole; //Forward declaration

struct Image
{
    void* pixels;
    ivec2 size;
    i32   nchannels;
    i32   stride;
};

struct Texture
{
    GLuint      handle;
    std::string filepath;
};

struct VertexBufferAttribute
{
    u8 location;
    u8 componentCount;
    u8 offset;
};

struct VertexBufferLayout
{
    std::vector<VertexBufferAttribute> attributes;
    u8                                 stride;
};

struct VertexShaderAttribute
{
    u8 location;
    u8 componentCount;
};

struct VertexShaderLayout
{
    std::vector<VertexShaderAttribute> attributes;
};

struct Program
{
    GLuint             handle;
    std::string        filepath;
    std::string        programName;
    u64                lastWriteTimestamp; // What is this for?
    VertexShaderLayout vertexInputLayout;
};

struct Vao
{
    GLuint handle;
    GLuint programHandle;
};

struct Submesh
{
    VertexBufferLayout vertexBufferLayout;
    std::vector<float> vertices;
    std::vector<u32>   indices;
    u32                vertexOffset;
    u32                indexOffset;

    std::vector<Vao>   vaos;
};

struct Mesh
{
    std::vector<Submesh> submeshes;
    GLuint               vertexBufferHandle;
    GLuint               indexBufferHandle;
};

struct Material
{
    std::string name;
    vec3        albedo;
    vec3        emissive;
    f32         smoothness;
    u32         albedoTextureIdx;
    u32         emissiveTextureIdx;
    u32         specularTextureIdx;
    u32         normalsTextureIdx;
    u32         bumpTextureIdx;
};

struct Model
{
    u32              meshIdx;
    std::vector<u32> materialIdx;
};

struct Camera
{
    vec3 position = vec3(0.0f, 0.0f, 10.0f);
    vec3 target = vec3(0.0f, 0.0f, 0.0f);
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    float fov = 60.0f;
    float nearPlane = 0.1f;
    float farPlane = 100.0f;
    float speed = 5.0f; 
    glm::mat4 cameraMatrix;
    glm::mat4 projectionMatrix;
};

struct Entity
{
    glm::mat4   worldMatrix;
    u32         modelIndex;
    u32         localParamsOffset;
    u32         localParamsSize;
};

enum LightType
{
    LightType_Directional,
    LightType_Point
};

struct Light
{
    LightType type;
    vec3 color;
    vec3 direction;
    vec3 position;
};
struct Buffer
{
    GLuint  handle;
    GLenum  type;
    u32     size;
    u32     head;
    void*   data;
};

enum RenderMode
{
    Mode_Forward,
    Mode_Deferred
};

enum Mode
{
    Mode_ForwardRender,
    Mode_FinalRender,
    Mode_Depth,
    Mode_Normals,
    Mode_Albedo,
    Mode_Position,
    Mode_Count,
};

// - vertex buffers
struct VertexV3V2
{
    glm::vec3 pos;
    glm::vec2 uv;
};

const VertexV3V2 vertices[] =
{
    { glm::vec3(-1.0,  1.0, 0.0),   glm::vec2(0.0, 1.0) },    // top-left vertex
    { glm::vec3(-1.0, -1.0, 0.0),   glm::vec2(0.0, 0.0) },    // bottom-left vertex
    { glm::vec3(1.0,  1.0, 0.0),    glm::vec2(1.0, 1.0) },    // top-right vertex
    { glm::vec3(1.0, -1.0, 0.0),    glm::vec2(1.0, 0.0) },    // bottom-right vertex
};

const u16 indices[] =
{
    1, 3, 2, 1, 2, 0
};

struct App
{
    // Loop
    f32  deltaTime;
    bool isRunning;

    // Input
    Input input;

    // Graphics
    char gpuName[64];
    char openGlVersion[64];
    char vendor[64];
    char glslVersion[64];
    std::vector<std::string> glExtensions;

    bool showInfo = true;

    ivec2 displaySize;

    std::vector<Texture>  textures;
    std::vector<Program>  programs;
    std::vector<Material> materials;
    std::vector<Mesh>     meshes;
    std::vector<Model>    models;
    std::vector<Entity>   entities;
    std::vector<Light>   lights;

    // program indices
    u32 texturedMeshProgramIdx;
    u32 texturedGeometryProgramIdx;
    u32 deferredGeometryPassProgramIdx;
    u32 deferredShadingPassProgramIdx;
    u32 blitBrightestPixelsProgram;
    u32 blur;
    u32 bloomProgram;
    u32 SSAOPassProgramIdx;
    u32 SSAOBlurPassProgramIdx;

    // texture indices
    u32 diceTexIdx;
    u32 whiteTexIdx;
    u32 blackTexIdx;
    u32 normalTexIdx;
    u32 magentaTexIdx;

    // model indices
    u32 patrick;
    u32 sphere;
    u32 floor;
    u32 cat;

    // lights
    u32 globalParamsOffset;
    u32 globalParamsSize;
    Buffer cbuffer;

    // framebuffer
    GLuint depthAttachmentHandle;
    GLuint framebufferHandle;

    GLuint finalRenderAttachmentTexture;
    GLuint normalsAttachmentTexture;
    GLuint albedoAttachmentTexture;
    GLuint depthAttachmentTexture;
    GLuint positionAttachmentTexture;
    GLuint ssaoColorBuffer;
    GLuint noiseTexture;

    // bloom
    GLuint rtBright; 
    GLuint rtBloomH; 
    GLuint fboBloom1;
    GLuint fboBloom2;
    GLuint fboBloom3;
    GLuint fboBloom4;
    GLuint fboBloom5;
    int kernelRadius = 24;
    int lodIntensity0 = 1;
    int lodIntensity1 = 1;
    int lodIntensity2 = 1;
    int lodIntensity3 = 1;
    int lodIntensity4 = 1;
    float bloomThreshold = 0.25;
    bool renderBloom = true;


    // SSAO
    std::vector<glm::vec3> ssaoKernel;
    std::vector<glm::vec3> ssaoNoise;
    bool SSAO = true;
    float radius = 0.5f;
    float bias = 0.001f;

    // Render Mode
    RenderMode renderMode;
    
    // Mode
    Mode mode;

    GLint uniformBufferMaxSize;
    GLint uniformBufferAlignment;
    GLuint uniformBuffer;

    // Camera
    Camera mainCamera;

    // Embedded geometry (in-editor simple meshes such as
    // a screen filling quad, a cube, a sphere...)
    GLuint embeddedVertices;
    GLuint embeddedElements;

    // Location of the texture uniform in the textured quad shader
    GLuint programUniformTexture;

    // VAO object to link our screen filling quad with our textured quad shader
    GLuint vao;

    //Render mode
    int comboItem = 0;

    //Console
    EditorConsole* console = nullptr;
};

void Init(App* app);

void Gui(App* app);

void Update(App* app);

void Render(App* app);

u32 LoadTexture2D(App* app, const char* filepath);

void CreateFboTexture(GLuint& textureHandle, ivec2 displaySize, GLint type);