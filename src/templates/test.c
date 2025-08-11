#ifndef HOKUSAI_NATIVE
#define HOKUSAI_NATIVE
#include "graal_isolate.h"
#include "libhokusai-native.h"
#include "../../../include/hokusai-native-ext.h"
#include "raylib.h"
#include "hashmap.h"
#include "string.h"
#include <stdlib.h>
#include <stdio.h>

typedef struct TextureCache
{
  char* key;
  Texture payload;
} texture_cache;

static struct hashmap* textures = NULL;

void texture_free(texture_cache* texture)
{
  free(texture->key);
  free(texture);
}

int texture_compare(const void* a, const void* b, void* udata)
{
	const texture_cache* prop_a = (texture_cache*) a;
	const texture_cache* prop_b = (texture_cache*) b;
	return strcmp(prop_a->key, prop_b->key);
}

uint64_t texture_hash(const void* item, uint64_t seed0, uint64_t seed1)
{
	texture_cache* texture = (texture_cache*) item;
	return hashmap_sip(texture->key, strlen(texture->key), seed0, seed1);
}

void on_draw_rect(hokusai_native_rect_command* command)
{
  Color color = (Color){ .r=command->color->red, .g=command->color->green, .b=command->color->blue, .a=command->color->alpha };
  DrawRectangle(command->x, command->y, command->width, command->height, color);
}

void on_draw_circle(hokusai_native_circle_command* command)
{
  Color color = (Color){ .r=command->color->red, .g=command->color->green, .b=command->color->blue, .a=command->color->alpha };
  DrawCircleV((Vector2){command->x, command->y}, command->radius, color);
}

void on_draw_text(hokusai_native_text_command* command)
{
  Color color = (Color){ .r=command->color->red, .g=command->color->green, .b=command->color->blue, .a=command->color->alpha };
  DrawText(command->content, command->x, command->y, command->size, color);
}

void on_draw_scissor_begin(hokusai_native_scissor_begin_command* command)
{
  BeginScissorMode(command->x, command->y, command->width, command->height);
}

void on_draw_scissor_end(void)
{
  EndScissorMode();
}

void on_draw_image(hokusai_native_image_command* command)
{
  Texture tex;
  int len = strlen(command->source) + 100; 
  char hash[len];
  sprintf(hash, "%s-%.2f-%.2f", command->source, command->width, command->height);
  const texture_cache* result = hashmap_get(textures, &(texture_cache){ .key=hash });
  if (result == NULL)
  {
    Image img = LoadImage(command->source);
    ImageResize(&img, command->width, command->height);
    Texture texture = LoadTextureFromImage(img);
    UnloadImage(img);
    GenTextureMipmaps(&texture);
    hashmap_set(textures, &(texture_cache){ .key=strdup(hash), .payload=texture});
    tex = texture;
  }
  else
  {
    tex = result->payload;
  }
  
  DrawTexture(tex, command->x, command->y, WHITE);
}

static char* fslurp(FILE *fp)
{
  char* source =  NULL;
  if (fp != NULL) {
    /* Go to the end of the file. */
    if (fseek(fp, 0L, SEEK_END) == 0) {
        /* Get the size of the file. */
        long bufsize = ftell(fp);
        if (bufsize == -1) { /* Error */ }

        /* Allocate our buffer to that size. */
        source = malloc(sizeof(char) * (bufsize + 1));

        /* Go back to the start of the file. */
        if (fseek(fp, 0L, SEEK_SET) != 0) { /* Error */ }

        /* Read the entire file into memory. */
        size_t newLen = fread(source, sizeof(char), bufsize, fp);
        if (newLen == 0) {
            fputs("Error reading file", stderr);
        } else {
            source[newLen] = '\0'; /* Just to be safe. */
        }
    }
    fclose(fp);
  }

  return source;
}

int main(int argc, char* argv[])
{
  graal_isolatethread_t* isolate = createIsolate();

  char* filename = argv[1];
  FILE* fp = fopen(filename, "r");
  const char* buffer = fslurp(fp);
  const int screenWidth = 800;
  const int screenHeight = 450;

  textures = hashmap_new(sizeof(texture_cache), 0, 0, 0, texture_hash, texture_compare, NULL, texture_free);

  init((long long int)isolate, buffer);
  onDrawRect((long long int)isolate, &on_draw_rect);
  onDrawCircle((long long int)isolate, &on_draw_circle);
  onDrawText((long long int)isolate, &on_draw_text);
  onDrawScissorBegin((long long int)isolate, &on_draw_scissor_begin);
  onDrawScissorEnd((long long int) isolate, &on_draw_scissor_end);
  onDrawImage((long long int)isolate, &on_draw_image);

  InitWindow(screenWidth, screenHeight, "Test");
  SetWindowState(FLAG_WINDOW_RESIZABLE);
  SetTargetFPS(60);

  while (!WindowShouldClose())
  {
    // process_input(isolate);
    BeginDrawing();
      if (IsWindowFocused())
      {
        DisableEventWaiting();
      }
      else
      {
        EnableEventWaiting();
      }

      int lwidth = GetScreenWidth();
      int lheight = GetScreenHeight();

      ClearBackground(RAYWHITE);
      update((long long int)isolate);
      render((long long int)isolate, (float)lwidth, (float)lheight);
      DrawFPS(10, 10);
    EndDrawing();
  }

  free((void*)buffer);
  hashmap_free(textures);
  CloseWindow();
  return 0;
}

#endif