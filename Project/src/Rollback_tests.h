#pragma once
#include <windows.h>
#include <winuser.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include "AllocMan.h"
#include <squirrel.h>
#include <sqrat.h>
#include "PatchUtils.h"
#include "util.h"
#include "log.h"
extern HSQUIRRELVM* VM;
size_t waitime = 8;

#define free_addr (0x2E1930_R)
#define calloc_addr (0x312387_R)
#define realloc_addr (0x306FCD_R)
#define malloc_addr (0x306FC2_R)


void GetSqVM_(){
    VM = (HSQUIRRELVM*)0x4DACE4_R; 
}


void RollbackUpdate(){
    
    if(GetKeyState(VK_SHIFT) & 0x8000 && waitime == 0){
        printf("Rollback ! \n");
        rollback_allocs(7);
        waitime = 8;
    }
    if(waitime > 0){
        waitime--;
    }
    tick_allocs();
    //tick_allocs();
}

void hook_initialization(){
    GetSqVM_();
    //sq_throwerror(*VM,_SC("Hi"));
    HSQUIRRELVM vm = *VM;
    Sqrat::RootTable rtable(vm);
    Sqrat::Table rollback_table(vm);
    rtable.Bind(_SC("rollback"), rollback_table);
    rollback_table.Func(_SC("RollbackUpdate"), RollbackUpdate);

    printf("Hook init end \n");
    
}

void hook_for_allocpatches(){
    printf("WinMain \n");
    log_printf("WinMain \n");
    //patch_allocman();
}

void nop(){
    return;
}

void rollback_test_mod_init(){
    uintptr_t addr = 0x79443_R;
    hotpatch_jump((void*)addr, (void*)hook_initialization);

}