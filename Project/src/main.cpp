#include <string.h>
#include <squirrel.h>

#include "util.h"
#include "InputVisualizer.h"


const uintptr_t base_address = (uintptr_t)GetModuleHandleA(NULL);
uintptr_t libact_base_address = 0;

//SQVM Rx4DACE4 initialized at Rx124710
HSQUIRRELVM* VM;

void GetSqVM(){
    VM = (HSQUIRRELVM*)0x4DACE4_R; 
}


void Debug() {
    AllocConsole();
    (void)freopen("CONIN$","r",stdin);
    (void)freopen("CONOUT$","w",stdout);
    (void)freopen("CONOUT$","w",stderr);
    SetConsoleTitleW(L"th155r debug");
}

// Initialization code shared by th155r and thcrap use
// Executes before the start of the process
void common_init() {
#ifndef NDEBUG
    Debug();
#endif

}

void yes_tampering() {
    hotpatch_ret(0x12E820_R, 0);
    hotpatch_ret(0x130630_R, 0);
    hotpatch_ret(0x132AF0_R, 0);
}

extern "C" {
    // FUNCTION REQUIRED FOR THE LIBRARY
    // th155r init function
    dll_export int stdcall netcode_init(int32_t param) {
        yes_tampering();
        common_init();
        return 0;
    }
    
    // thcrap init function
    // Thcrap already removes the tamper protection,
    // so that code is unnecessary to include here.
    dll_export void cdecl netcode_mod_init(void* param) {
        common_init();
        rollback_test_mod_init();
    }
    
    // thcrap plugin init
    dll_export int stdcall thcrap_plugin_init() {
        if (HMODULE thcrap_handle = GetModuleHandleA("thcrap.dll")) {
            if (auto runconfig_game_get = (const char*(*)())GetProcAddress(thcrap_handle, "runconfig_game_get")) {
                const char* game_str = runconfig_game_get();
                if (game_str && !strcmp(game_str, "th155")) {
                    return 0;
                }
            }
        }
        return 1;
    }
}

void Cleanup(){
    return;
}

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD dwReason, LPVOID reserved) {
    if (dwReason == DLL_PROCESS_DETACH) {
        Cleanup();
    }
    return TRUE;
}