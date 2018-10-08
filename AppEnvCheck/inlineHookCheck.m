//
//  inlineHookCheck.h
//  AppEnvCheck
//
//  Created by liaogang on 2018/10/8.
//  Copyright © 2018年 liaogang. All rights reserved.
//
#import "inlineHookCheck.h"
#import "defs.h"
#import <stdio.h>
#import <fcntl.h>
#import <dlfcn.h>
#import <unistd.h>
#import <stdlib.h>


int inline_hook_check(__int64 a1)
{
    const _DWORD magic0 = 0x058000050;//arm64的跳转指令
    const _DWORD magic1 = 0x0d61f0200;
    
    const _DWORD magic2 = 0x058000051;
    const _DWORD magic3 = 0x0d61f0220;
    
    
    int v5;
    int v6;
    int v7;
    
    v5 = *(_DWORD *)(a1 + 4);
    
    if ( *(_DWORD *)a1 ==  magic0 )
        v6 = (v5 ==  magic1);
        else
            v6 = 0;
            
            
            if ( !v6 )
            {
                v7 = *(_DWORD *)a1 == magic2 ? v5 == magic3 : 0;
                if ( !v7 )
                    return 0;
            }
    
    
    if ( !*(_QWORD *)(a1 + 8) )
        return 0;
    
    return 1;
}



void test_inline_hook_check()
{
    printf("\n\n\n---inline hook check---\n");
    int hooked;
    
    hooked = inline_hook_check( &open);
    printf("open hooked: %d\n",hooked);
    
    hooked = inline_hook_check( &dladdr);
    printf("dladdr hooked: %d\n",hooked);
    
    hooked = inline_hook_check( &read);
    printf("read hooked: %d\n",hooked);
    
    hooked = inline_hook_check( &getenv);
    printf("getenv hooked: %d\n",hooked);
    
    hooked = inline_hook_check( &getchar);
    printf("getchar hooked: %d\n",hooked);

}
