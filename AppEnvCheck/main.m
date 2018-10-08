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
#include <mach/mach_init.h>
#include <mach/mach_port.h>
#include <mach/task_info.h>
#include <mach/thread_act.h>
#include <mach/vm_map.h>
#include <mach/task.h>



@import Darwin.POSIX.pthread.pthread;
@import Darwin.Mach.mach_init;
@import Darwin.Mach.task;
@import MachO.loader;




typedef struct HookNode {
    void* beg;
    void* end;
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
    if( header->ncmds )
    {
        __int64 vmaddr = 0;
        int cmdIndex = 0;

        void *loadCmd = header + 1 ;
        struct segment_command_64 *sc = (struct segment_command_64 *)loadCmd;


        while ( TRUE )
        {
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

    }

}


void _prepare_root()
{
    rootNode = malloc(sizeof(HookNode));
    bzero(rootNode, sizeof(HookNode));
}


void prepare_fish_hook_check()
{
    _prepare_root();
    

    integer_t task_info_out[TASK_DYLD_INFO_COUNT];
    mach_msg_type_number_t task_info_outCnt = TASK_DYLD_INFO_COUNT;
    if( task_info( mach_task_self_ , TASK_DYLD_INFO , task_info_out, &task_info_outCnt) == KERN_SUCCESS )
    {
        struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(task_info_out);
        struct dyld_all_image_infos* infos = (struct dyld_all_image_infos *) dyld_info.all_image_info_addr;
        struct dyld_uuid_info* pUuid_info  = (struct dyld_uuid_info*) infos->uuidArray; //v4

        
        struct HookNode *curr;
        struct HookNode *i;
        struct HookNode *next;

        curr = rootNode;

        
        if ( infos->uuidArrayCount )
        {
            unsigned __int64 index = 1;

            for ( i = rootNode ; ;  )
            {
                const struct mach_header_64 *header =  (const struct mach_header_64 *)pUuid_info->imageLoadAddress;

                curr->index = (signed __int64)(index - 1) > 1;

                
                QWORD v11;
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

    }

}





char *(*getenv0)(const char *);
char *getenv1(const char *arg)
{
    NSLog(@"my getenv");
    return NULL;
}


static int (*orig_open)(const char *, int, ...);
int new_open(const char *path, int oflag, ...) {
    
    NSLog(@"my open");
    
    va_list ap = {0};
    mode_t mode = 0;
    
    if ((oflag & O_CREAT) != 0) {
        // mode only applies to O_CREAT
        va_start(ap, oflag);
        mode = va_arg(ap, int);
        va_end(ap);
        return orig_open(path, oflag, mode);
    } else {
        return orig_open(path, oflag, mode);
    }
}

void checkSomeFunc()
{
    BOOL hooked;
    
    hooked = fishHooked( &open);
    printf("open hooked: %d\n",hooked);
    
    hooked = fishHooked( &dladdr);
    printf("dladdr hooked: %d\n",hooked);
    
    hooked = fishHooked( &read);
    printf("read hooked: %d\n",hooked);
    
    hooked = fishHooked( &getenv);
    printf("getenv hooked: %d\n",hooked);
}

int main(int argc, char * argv[]) {
    
    prepare_fish_hook_check();
    
    
    checkSomeFunc();
    
    {
        struct rebinding open_rebinding = { "getenv", (void*)getenv1, (void **)&getenv0 };
        rebind_symbols((struct rebinding[1]){open_rebinding}, 1);
    }
    
    {
        struct rebinding open_rebinding = { "open", (void*)new_open, (void **)&orig_open };
        rebind_symbols((struct rebinding[1]){open_rebinding}, 1);
    }
    
    
    open("/var/mobile/Media/a.txt", 'r');
    getenv("DYLD_INSERT_LIBRARY");


    checkSomeFunc();
    

    return 0;
}
