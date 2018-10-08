//
//  main.m
//  AppEnvCheck
//
//  Created by liaogang on 2018/9/30.
//  Copyright © 2018年 liaogang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fishhook.h"
#import "defs.h"
#import <dlfcn.h>
#include <mach-o/dyld_images.h>

#include <stdio.h>

#include <mach/mach_init.h>
#include <mach/mach_port.h>
#include <mach/task_info.h>
#include <mach/thread_act.h>
#include <mach/vm_map.h>
#include <mach/task.h>

#include <sys/types.h>
#include <sys/time.h>
#include <sys/proc.h>
#include <sys/sysctl.h>

#include <math.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

@import Darwin.POSIX.pthread.pthread;
@import Darwin.Mach.mach_init;
@import Darwin.Mach.task;
@import MachO.loader;




typedef struct HookNode {
    void* beg; //+8
    void* end; //+16
    
    BYTE index;

    struct HookNode *next; //+32
} HookNode;


static struct HookNode *rootNode = NULL;



/*
 检测传入的函数地址是不是位于(_TEXT,__text)之中，
 如果在说明是自己实现的伪函数，则位于(_TEXT,__text)之中
 如果是系统的原函数，则位于 (__DATAl,a_symbol_ptr)里的
*/
BOOL inMachOSegTEXT(void *funcAddr)
{
    BOOL inTEXT = FALSE;
    struct HookNode *node;
    for ( node = rootNode; node; node = node->next ) {
        
        if (funcAddr > node->beg && funcAddr < node->end) {
            inTEXT = TRUE;
            break;
        }

    }
    
    return inTEXT;
}

BOOL fishHooked(void *funcAddr)
{
    return inMachOSegTEXT(funcAddr);
}

void find_mach0_file_text_seg_range( struct mach_header_64 *header , __int64 *begin, _QWORD *end)
{
    NSLog(@"mach_header filetype: %d",header->filetype);
    //#define    MH_EXECUTE    0x2        /* demand paged executable file */

    
    if( header->ncmds )
    {
        __int64 vmaddr = 0;
        int cmdIndex = 0;

        void *loadCmd = header + 1 ;
        struct segment_command_64 *sc = (struct segment_command_64 *)loadCmd;


        while ( TRUE )
        {
            NSLog(@"sc->segname: %s",sc->segname);

            
            if ( sc->cmd == LC_SEGMENT_64 )     // value == 0x19 // is segment?
            {
                if ( !vmaddr )
                {
                    bool a = sc->fileoff;
                    bool b = !sc->filesize;
                    bool aa = a || b ;
                    
                    if( aa )
                        vmaddr = 0;
                    else
                    {
                        vmaddr = (__int64)header - sc->vmaddr;
                    }
                }

                
                if( strcmp(sc->segname, "__TEXT") == 0 )
                {
                    break;
                }
                
            }

            
            sc = (struct segment_command_64*)((BYTE*)sc + sc->cmdsize);
            
            if ( ++cmdIndex >= header->ncmds )
                return ;
        }
        
        
        __int64 v10 = sc->fileoff + (__int64)header;

        *begin = v10;
        *end = v10 + (_QWORD)sc->filesize;

        
        if(sc->filesize > 0)
        {
            NSLog(@"func open address: %p",&open);
            
            void *funcAddress = &open;
            if ( funcAddress > *begin && funcAddress < *end ) {
                NSLog(@"hooked");
            }
        }
        
        
    }
    
    
}


__int64 find_load_commands_old(__int64 result, __int64 *a2, _QWORD *a3)
{
    _QWORD *v3; // x19
    __int64 *v4; // x20
    __int64 v5; // x21
    unsigned int v6; // w24
    __int64 v7; // x26
    int v8; // w25
    signed __int64 v9; // x23
    __int64 v10; // x8
    
    v3 = a3;
    v4 = a2;
    v5 = result;
    struct mach_header *header = (struct mach_header *)result;
    v6 = *(_DWORD *)(result + 16); // header->ncmds
    if ( v6 )
    {
        v7 = 0LL;
        v8 = 0;
        v9 = result + 0x20 ; // ,     _PAGEZERO
        while ( 1 )
        {
            NSLog(@"segment name: %s" , (const char *)(v9 + 0x08));

            
            if ( *(_DWORD *)v9 == 0x19 )     // value == 0x19
            {
                if ( !v7 )
                {
                    //result + 48,  result + 50
                    //command size ,file size
                    
                    _QWORD a = *(_QWORD *)(v9 + 0x28);
                    _QWORD b = *(_QWORD *)(v9 + 0x30 );
                    
                    bool ba = a;
                    bool bb = !b;
                    
                    bool aa = ba || bb;
                    if( aa )
//                    if ( *(_QWORD *)(v9 + 0x28) || !*(_QWORD *)(v9 + 0x30 ) )
                        v7 = 0LL;
                    else
                    {
                        //result + 0x38 , vm address
//                        NSLog(@"sc,vmaddr: %p,%llu", *(_QWORD *)(v9 + 0x18 ) );
                        _QWORD vmaddr = *(_QWORD *)(v9 + 0x18 );
                        v7 = v5 - vmaddr;
                        NSLog(@"vmaddr: %llu, %lld",vmaddr, v7);
                    }
                    // v7 = (header - vm address)
                }
                
                //result + 0x28, segment name
                result = strcmp((const char *)(v9 + 0x08), "__TEXT");
                if ( !(_DWORD)result )
                    break;
            }
            v9 += *(unsigned int *)(v9 + 4);
            if ( ++v8 >= v6 )
                return result;
        }
        
        //result + 0x48 , result + 38
        //file offset + (header - *vm address) + vmaddress?
        //
        v10 = *(_QWORD *)(v9 + 0x28) + v7 + *(_QWORD *)(v9 + 0x18);
        *v4 = v10;
        //v4 = file offset + header ?
        
        //file size
        _QWORD filesize =*(_QWORD *)(v9 + 0x30);
        *v3 = v10 + filesize ;
        
        NSLog(@"sc filesize: %llu", filesize );

        NSLog(@"result: %lld,%lld,%lld, %llu",v7,v10,*v4,*v3);
        
        int asdf = 0;
    }
    return result;
}



void _prepare_root()
{
    rootNode = malloc(sizeof(HookNode));
    bzero(rootNode, sizeof(HookNode));
}

__int64 prepare_fish_hook_check()
{
    _prepare_root();
    
    __int64 result;

    struct HookNode *curr;

    struct HookNode *i;

    struct HookNode *next;

    
    
    integer_t task_info_out[TASK_DYLD_INFO_COUNT];
    mach_msg_type_number_t task_info_outCnt = TASK_DYLD_INFO_COUNT;
    result = task_info( mach_task_self_ , TASK_DYLD_INFO , task_info_out, &task_info_outCnt);
    if ( result == KERN_SUCCESS )
    {
        struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(task_info_out);
        struct  dyld_all_image_infos* infos = (struct dyld_all_image_infos *) dyld_info.all_image_info_addr;

        struct dyld_uuid_info* pUuid_info  = (struct dyld_uuid_info*) infos->uuidArray; //v4
        const struct dyld_image_info*    infoArray = infos->infoArray;
        
        

        curr = rootNode;

        
        if ( infos->uuidArrayCount )
        {
            unsigned __int64 index = 1;
            
            void *v0;
            //Dl_info v15;
            //dladdr(prepare_fish_hook_check, &v15);
            //v0 = v15.dli_fbase;
            NSLog(@"image base index: %d",index-1);
            
            for ( i = rootNode ; ;  )
            {
                const struct mach_header_64 *header =  pUuid_info->imageLoadAddress;

                
//                i->isMain = (header == v0);

                curr->index = (signed __int64)(index - 1) > 1;

                
                __int64 v11;
                __int64 v12;
                

                
                find_mach0_file_text_seg_range(header, &v12, &v11);
                i->beg = v12;
                i->end = v11;


                next = i->next;
                if ( next == NULL )
                {
                    next = malloc(sizeof(struct HookNode));
                    bzero(next, sizeof(struct HookNode));
                    i->next = next;
                }
                
                
                if ( index >= infos->uuidArrayCount )
                    break;
                
                pUuid_info = pUuid_info + 1;
                curr = rootNode;
                ++index;
                i = next;
            }
            
            
            curr = next;
        }
        else
        {
            next = rootNode;
        }
        
        
        /*
        _QWORD *j;
        _QWORD *v10;
        for ( j = *(_QWORD **)(curr + 32); j; next = v10 )
        {
            v10 = j;
            //free(v8);
            j = (_QWORD *)v10[4];
        }
        */
        
    }
    
    
    return 0;
}






static int (*orig_open)(const char *, int, ...);
int new_open(const char *path, int oflag, ...) {
    va_list ap = {0};
    mode_t mode = 0;
    
    if ((oflag & O_CREAT) != 0) {
        // mode only applies to O_CREAT
        va_start(ap, oflag);
        mode = va_arg(ap, int);
        va_end(ap);
//        printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
        return orig_open(path, oflag, mode);
    } else {
//        printf("Calling real open('%s', %d)\n", path, oflag);
        return orig_open(path, oflag, mode);
    }
}



int main(int argc, char * argv[]) {
    
    
    // 初始化一个 rebinding 结构体
    struct rebinding open_rebinding = { "open", (void*)new_open, (void **)&orig_open };
    
    // 将结构体包装成数组，并传入数组的大小，对原符号 open 进行重绑定
    rebind_symbols((struct rebinding[1]){open_rebinding}, 1);
    
    
    
    NSLog(@"func open address: %p",&open);
    open("/var/mobile/Media/a.txt", 'r');
    
    //初始化链表
    prepare_fish_hook_check();
    
    
    int hooked;
    
    hooked = fishHooked( (unsigned __int64)&open);
    printf("hooked: %d\n",hooked);
    
    hooked = fishHooked( (unsigned __int64)&dladdr);
    printf("hooked: %d\n",hooked);
    
    hooked = fishHooked( (unsigned __int64)&open);
    printf("hooked: %d\n",hooked);
    
    hooked = fishHooked( (unsigned __int64)&dladdr);
    printf("hooked: %d\n",hooked);
    

    
    
    
    
    while (getchar() == 'q') {
        return 0;
    }
    
    
    while (1) {
        sleep(3);
    }
    
    
    
    return 0;
}
