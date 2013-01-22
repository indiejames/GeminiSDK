/*
** $Id: linit.c,v 1.32 2011/04/08 19:17:36 roberto Exp $
** Initialization of libraries for lua.c and other clients
** See Copyright Notice in lua.h
*/


/*
** If you embed Lua in your program and need to open the standard
** libraries, call luaL_openlibs in your program. If you need a
** different set of libraries, copy this file to your project and edit
** it to suit your needs.
*/


#define linit_c
#define LUA_LIB

#include "lua.h"

#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_geminiObjectLib (lua_State *L);
extern int luaopen_soundlib (lua_State *L);
extern int luaopen_spritelib (lua_State *L);
extern int luaopen_system_lib (lua_State *L);
extern int luaopen_display_lib (lua_State *L);
extern int luaopen_transition_lib (lua_State *L);
extern int luaopen_timer_lib(lua_State *L);
extern int luaopen_event_lib(lua_State *L);
extern int luaopen_director_lib(lua_State *L);
extern int luaopen_physics_lib(lua_State *L);
extern int luaopen_particle_system_lib(lua_State *L);
extern int luaopen_text_lib(lua_State *L);
extern int luaopen_UI_lib (lua_State *L);
extern int luaopen_lsqlite3(lua_State *L);

/*
** these libs are loaded by lua.c and are readily available to any Lua
** program
*/
static const luaL_Reg loadedlibs[] = {
    {"_G", luaopen_base},
    {LUA_LOADLIBNAME, luaopen_package},
    {LUA_COLIBNAME, luaopen_coroutine},
    {LUA_TABLIBNAME, luaopen_table},
    {LUA_IOLIBNAME, luaopen_io},
    {LUA_OSLIBNAME, luaopen_os},
    {LUA_STRLIBNAME, luaopen_string},
    {LUA_BITLIBNAME, luaopen_bit32},
    {LUA_MATHLIBNAME, luaopen_math},
    {LUA_DBLIBNAME, luaopen_debug},
    {"gemini", luaopen_geminiObjectLib},
    {"system", luaopen_system_lib},
    {"event", luaopen_event_lib},
    {"director", luaopen_director_lib},
    {"display", luaopen_display_lib},
    {"transition", luaopen_transition_lib},
    {"text", luaopen_text_lib},
    {"UI", luaopen_UI_lib},
    {"sqlite3", luaopen_lsqlite3},
    {NULL, NULL}
};


/*
** these libs are preloaded and must be required before use
*/
static const luaL_Reg preloadedlibs[] = {
    {"sound", luaopen_soundlib},
    {"sprite", luaopen_spritelib},
    {"physics", luaopen_physics_lib},
    {"timer", luaopen_timer_lib},
    {"particle_system", luaopen_particle_system_lib},
  {NULL, NULL}
};


LUALIB_API void luaL_openlibs (lua_State *L) {
  const luaL_Reg *lib;
  /* call open functions from 'loadedlibs' and set results to global table */
  for (lib = loadedlibs; lib->func; lib++) {
    luaL_requiref(L, lib->name, lib->func, 1);
    lua_pop(L, 1);  /* remove lib */
  }
  /* add open functions from 'preloadedlibs' into 'package.preload' table */
  luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
  for (lib = preloadedlibs; lib->func; lib++) {
    lua_pushcfunction(L, lib->func);
    lua_setfield(L, -2, lib->name);
  }
  lua_pop(L, 1);  /* remove _PRELOAD table */
}

