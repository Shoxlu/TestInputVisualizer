#pragma once
#include <windows.h>
#include <winuser.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <squirrel.h>
#include <sqrat.h>
#include <vector>
#include "PatchUtils.h"
extern HSQUIRRELVM* VM;
std::vector<const char*> inputs;

void GetSqVM_(){
    VM = (HSQUIRRELVM*)0x4DACE4_R; 
}


SQInteger Printf(const char* pressed_input){
    printf("Input pressed: %s", pressed_input);
   // inputs.emplace_back(pressed_input);
    return 0;
}


void hook_initialization(){
    GetSqVM_();
    //sq_throwerror(*VM,_SC("Hi"));
    HSQUIRRELVM vm = *VM;
    Sqrat::RootTable rtable(vm);
    Sqrat::Table inputvisualizer_table(vm);
    rtable.Bind(_SC("inputvisualizerDebug"), inputvisualizer_table);
    inputvisualizer_table.Func(_SC("Printf"), Printf);

    printf("Hook init end \n");
    
}

void hook_for_allocpatches(){
    printf("WinMain \n");
    //patch_allocman();
}

void rollback_test_mod_init(){
    uintptr_t addr = 0x79443_R;
    hotpatch_jump((void*)addr, (void*)hook_initialization);

}