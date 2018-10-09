//
//  uncacheModules.c
//  AppEnvCheck
//
//  Created by liaogang on 2018/10/9.
//  Copyright © 2018年 liaogang. All rights reserved.
//

#include "uncacheModules.h"
#include "defs.h"
#include <mach/task_info.h>
#include <mach/task.h>
#include <mach-o/dyld_images.h>
#include <stdlib.h>
#include <mach-o/loader.h>
#import <Foundation/Foundation.h>

/*
 可以用MachoView打开一个dylib了解详细
 定位到 dylib , Load Commands下的LC_ID_DYLIB 一节下，找到此动态库的路径全名
 如: /Library/MobileSubstrate/DynamicLibraries/awemeHOOK.dylib
*/
void  print_mach_header_dylib_name(const struct mach_header_64* mheader)
{
    if(mheader->magic == MH_MAGIC_64 && mheader->ncmds > 0)
    {
        void *loadCmd = (void*)(mheader + 1) ;
        struct segment_command_64 *sc = (struct segment_command_64 *)loadCmd;
        
        for ( int index = 0; index < mheader->ncmds; ++index , sc = (struct segment_command_64*)((BYTE*)sc + sc->cmdsize))
        {
            
            if (sc->cmd == LC_ID_DYLIB) {
                
                struct dylib_command *dc = (struct dylib_command *)sc;
                struct dylib dy = dc->dylib;
                char *str = (char*)dc + dy.name.offset;
                

                NSLog(@"%s",str);
                
                //第二种方法
                //也可以用vm_read_overwrite来读取信息
                break;
            }
            
        }
        
    }
}






void getAllUncachedModules()
{
    NSLog(@"--- getAllUncachedModules ---");

    integer_t task_info_out[TASK_DYLD_INFO_COUNT];
    mach_msg_type_number_t task_info_outCnt = TASK_DYLD_INFO_COUNT;
    if( task_info( mach_task_self_ , TASK_DYLD_INFO , task_info_out, &task_info_outCnt) == KERN_SUCCESS )
    {
        struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(task_info_out);
        struct dyld_all_image_infos* infos = (struct dyld_all_image_infos *) dyld_info.all_image_info_addr;
        
        /* only images not in dyld shared cache 相比于infoarray ，这里过滤掉了在dyld_shared_cache里面的那些库 */
        struct dyld_uuid_info* pUuid_info  = (struct dyld_uuid_info*) infos->uuidArray; //v4

        for( int i = 0 ; i < infos->uuidArrayCount; i++, pUuid_info += 1)
        {
            const struct mach_header_64* mheader = (const struct mach_header_64*)pUuid_info->imageLoadAddress;
            if (mheader->filetype == MH_DYLIB) {
                print_mach_header_dylib_name(mheader);
            }
            
        }
    }
    
    
    NSLog(@"--- end ---");
}







