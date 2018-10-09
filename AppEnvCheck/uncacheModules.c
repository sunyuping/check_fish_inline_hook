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


__int64 sub_101BB4A94(__int64 a1, __int64 a2, __int64 a3)
{
    __int64 v3; // x19
    __int64 v4; // x8
    int v5; // w9
    
    v3 = a1;
    if ( a3 )
    {
        v4 = 0LL;
        while ( 1 )
        {
            v5 = *(unsigned __int8 *)(a2 + v4);
            *(_BYTE *)(a1 + v4) = v5;
            if ( !v5 )
                break;
            if ( a3 == ++v4 )
                return v3;
        }
        if ( a3 - 1 != v4 )
            bzero((void *)(a1 + v4 + 1), a3 - v4 - 1);
    }
    return v3;
}


signed __int64 sub_101BB4BB0(mach_port_t a1, vm_address_t a2, vm_address_t a3, vm_size_t a4)
{
    vm_size_t v4; // x20
    void *v5; // x19
    mach_port_t v6; // w8
    signed __int64 result; // x0
    mach_port_t v8; // w0
    bool v9; // zf
    size_t v10; // [xsp+8h] [xbp-18h]

    
    struct segment_command_64 *sc = (struct segment_command_64 *)a3;

    
    v4 = a4;
    v5 = (void *)a2;
    v6 = a1;
    result = 0LL;
    v10 = 0LL;
    if ( a2 && a3 && a4 )
    {
        if ( v6 )
            v8 = v6;
        else
            v8 = mach_task_self_;
        
//        vm_read_overwrite(mach_task_self_, sc , sc->cmdsize, a2, &v10) ;
        //vm_read_overwrite 读取进程的信息
        if ( vm_read_overwrite(v8, a3, a4, a2, &v10) )
            v9 = 0;
        else
            v9 = v10 == v4;
        
        
        if ( v9 )
        {
            result = 1LL;
        }
        else
        {
            bzero(v5, v10);
            result = 0LL;
        }
        
        
    }
    return result;
}


/*
 可以用MachoView打开一个dylib了解详细
 定位到 dylib , Load Commands下的LC_ID_DYLIB 一节下，找到此动态库的路径全名: 如/Library/MobileSubstrate/DynamicLibraries/awemeHOOK.dylib
 */
//mheader
signed __int64 sub_101BB66E0(_DWORD *a1, void *a2)
{
    void *v2; // x19
    signed __int64 v3; // x20
    unsigned int v4; // w8
    int v5; // w9
    _DWORD *v6; // x20
    size_t v7; // x0
    unsigned int *v9; // x21
    int v10; // w0
    __int64 v11; // x22
    
    const struct mach_header_64* mheader = a1;
    v2 = a2;
    v3 = 0xFFFFFFFFLL;
    if ( a1 && a2 )
    {

        if(mheader->magic == MH_MAGIC_64)
//        if ( *a1 == MH_MAGIC_64 )
        {
            int iii = sizeof(_DWORD);
            int iiii = sizeof(struct mach_header_64);
            
            
            
            v4 = a1[4];
            mheader->ncmds;
            
            
            if(mheader->ncmds > 0)
//            if ( v4 )
            {
                v5 = 0; //index
                
                v6 = a1 + 8;
                void *loadCmd = mheader + 1 ;
                struct segment_command_64 *sc = (struct segment_command_64 *)loadCmd;

                
                while ( 1 )
                {
                    v7 = (unsigned int)v6[1];
                    sc->cmdsize;
                    
                    if (sc->cmd == LC_ID_DYLIB) {
                        break;
                    }
                    
//                    if ( *v6 == 0xD )
//                        break;
                    
                    
                    //next
                    sc = (struct segment_command_64*)((BYTE*)sc + sc->cmdsize);
                    v6 = (_DWORD *)((char *)v6 + v7);
                    
                    
                    if ( ++v5 >= v4 )
                        goto LABEL_8;
                }
                
                
                
                
//                v9 = (unsigned int *)malloc(v7);
                v9 = (unsigned int *)malloc(sc->cmdsize);

                
                unsigned int v66 = v6[1];
                v6;
                v10 = sub_101BB4BB0(0LL, v9, sc, (unsigned int)sc->cmdsize);
//                v10 = sub_101BB4BB0(0LL, v9, v6, (unsigned int)v6[1]);
                
                
                if ( v9 && !((v10 ^ 1) & 1) )
                {
                    v3 = 0LL;
                    v11 = (__int64)v9 + v9[2];
                LABEL_16:
                    bzero(v2, 0x400uLL);
                    sub_101BB4A94((__int64)v2, v11, 1023LL);
                    free(v9);
                    return v3;
                }
                v3 = 0xFFFFFFFFLL;
                if ( v9 )
                {
                    v11 = 0LL;
                    goto LABEL_16;
                }
            }
            else
            {
            LABEL_8:
                v3 = 0LL;
            }
        }
        else
        {
            v3 = 0xFFFFFFFFLL;
        }
    }
    return v3;
}



char *sub_101BB4B70(char *result, char a2, char a3)
{
    char v3; // w8
    int v4; // t1
    
    if ( result )
    {
        v3 = *result;
        if ( *result )
        {
            do
            {
                if ( v3 == a2 )
                    *result = a3;
                v4 = (unsigned __int8)(result++)[1];
                v3 = v4;
            }
            while ( v4 );
        }
    }
    return result;
}


QWORD qword_103B8FDD8;

__int64 sub_101BB6678()
{
    __int64 result; // x0
    int v1; // [xsp+4h] [xbp-2Ch]
    __int64 v2; // [xsp+8h] [xbp-28h]
    
    result = qword_103B8FDD8;
    if ( !qword_103B8FDD8 )
    {
        v1 = 5;
        if ( task_info(mach_task_self_, 0x11u, (task_info_t)&v2, (mach_msg_type_number_t *)&v1) )
        {
            result = 0LL;
            qword_103B8FDD8 = 0LL;
        }
        else
        {
            struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(&v2);
            result = v2;
            qword_103B8FDD8 = v2;
        }
    }
    

    
    
    return result;
}


void getAllUncachedModules()
{
    sub_101BB6678();
    
    
    __int64 v15; // x19
    __int64 v16; // x0
    __int64 v17; // x21
    char v18; // w22
    __int64 v19; // x0
    unsigned __int64 v20; // x24
    unsigned __int64 v21; // x25
    signed __int64 v22; // x22
    __int64 v23; // x26
    _DWORD *v24; // x23
    void **v25; // x1
    void *v26; // x2
    signed int v27; // w23
    __int64 v28; // x8
    __int64 v29; // x0
    __int64 result; // x0
    __int64 v31; // [xsp+0h] [xbp-4B0h]
    void *v32; // [xsp+8h] [xbp-4A8h]
    char v33; // [xsp+1Fh] [xbp-491h]
    void *v34[2]; // [xsp+408h] [xbp-A8h]
    __int64 v35; // [xsp+418h] [xbp-98h]
    __int64 v36; // [xsp+420h] [xbp-90h]
    __int64 v37; // [xsp+428h] [xbp-88h]
    __int64 v38; // [xsp+430h] [xbp-80h]
    __int64 v39; // [xsp+438h] [xbp-78h]
    __int64 v40; // [xsp+440h] [xbp-70h]
    __int64 v41; // [xsp+448h] [xbp-68h]
    char v42; // [xsp+450h] [xbp-60h]
    
    //    v15 = a1;
    v42 = 0;
    v40 = 0LL;
    v41 = 0LL;
    v38 = 0LL;
    v39 = 0LL;
    v36 = 0LL;
    v37 = 0LL;
    
    integer_t task_info_out[TASK_DYLD_INFO_COUNT];
    mach_msg_type_number_t task_info_outCnt = TASK_DYLD_INFO_COUNT;
    if( task_info( mach_task_self_ , TASK_DYLD_INFO , task_info_out, &task_info_outCnt) == KERN_SUCCESS )
    {
        struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(task_info_out);
        struct dyld_all_image_infos* infos = (struct dyld_all_image_infos *) dyld_info.all_image_info_addr;
        
        /* only images not in dyld shared cache 相比于infoarray ，这里过滤掉了在dyld_shared_cache里面的那些库 */
        struct dyld_uuid_info* pUuid_info  = (struct dyld_uuid_info*) infos->uuidArray; //v4
        
        
        
        printf("%d\n", (void*)&(dyld_info.all_image_info_addr) - (void*)&dyld_info) ;
        printf("%d\n", (void*)&(dyld_info.all_image_info_size) - (void*)&dyld_info) ;
        printf("%d\n", (void*)&(dyld_info.all_image_info_format) - (void*)&dyld_info) ;
        
        
        
        
        printf("%d\n", (void*)&(infos->version) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->infoArrayCount) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->infoArray) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->dyldImageLoadAddress) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->uuidArrayCount) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->uuidArray) - (void*)infos) ;
        printf("%d\n", (void*)&(infos->dyldAllImageInfosAddress) - (void*)infos) ;
        
        /*
         cputype;    /* cpu specifier */
//        cpu_subtype_t    cpusubtype;    /* machine specifier */
//        uint32_t    filetype;    /* type of file */
//        uint32_t    ncmds;        /* number of load commands */
//        uint32_t    sizeofcmds;    /* the size of all the load commands */
//        uint32_t    flags;        /* flags */
//         */
        
  
        printf("uuidArrayCount: %d\n",infos->uuidArrayCount);
        
        
        
        
        v19 = (void*)task_info_out;
        v20 = infos->uuidArrayCount;
        
        if (  v20 > 0 )
        {
            v21 = 0LL;
            v22 = 0LL;
//            v23 = *(_QWORD *)(v19 + 96);
            
            pUuid_info;
            do
            {
//                v24 = *(_DWORD **)v23;
                
                const struct mach_header_64* mheader = pUuid_info->imageLoadAddress;
                /*0
                 8
                 12
                 16
                 20
                 24
                 */
//                printf("%d\n", (void*)&(mheader->magic) - (void*)mheader) ;
//                printf("%d\n", (void*)&(mheader->cpusubtype) - (void*)mheader) ;
//                printf("%d\n", (void*)&(mheader->filetype) - (void*)mheader) ;
//                printf("%d\n", (void*)&(mheader->ncmds) - (void*)mheader) ;
//                printf("%d\n", (void*)&(mheader->sizeofcmds) - (void*)mheader) ;
//                printf("%d\n", (void*)&(mheader->flags) - (void*)mheader) ;

                
                

                if (mheader->filetype != MH_DYLIB) {
                    goto LABEL_33;
                }
                
                
                //mheader->filetype != MH_DYLIB
//                if ( *(_DWORD *)(*(_QWORD *)v23 + 12LL) != 6 )
//                    goto LABEL_33;
                
                
                
                v34[1] = 0LL;
                v35 = 0LL;
                v34[0] = 0LL;
                
                v32 = malloc(0x400uLL);
                bzero(v32, 0x400uLL);
                
                
                
                printf("malloc: %p",v32);
                
                printf("get next mach header\n");
                
                
                
                if ( (unsigned int)sub_101BB66E0(mheader, v32) == -1 )
//                if ( (unsigned int)sub_101BB66E0(v24, &v32) == -1 )
                {
                    v27 = 0;
                }
                else
                {
                    char *str = v32;
                    printf("%s\n",str);
                    
                    
                    sub_101BB4B70((char *)v32, 34, 95);
//                    std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::assign(v34, &v32);
//                    std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::append(v15, "\"");
//                    if ( v35 >= 0 )
//                        v25 = v34;
//                    else
//                        v25 = (void **)v34[0];
//                    if ( v35 >= 0 )
//                        v26 = (void *)HIBYTE(v35);
//                    else
//                        v26 = v34[1];
//                    std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::append(v15, v25, v26);
//                    std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::append(v15, "\",");
//                    v27 = 1;
//                    v22 = 1LL;
                }
//                if ( SHIBYTE(v35) & 0x80000000 )
//                    operator delete(v34[0]);
                if ( v27 )
                    LABEL_33:
                    v23 += 24LL;
                ++v21;
                
                
                pUuid_info += 1;
            }
            while ( v21 < v20 );
            if ( (_DWORD)v22 == 1 )
            {
                v28 = *(unsigned __int8 *)(v15 + 23);
                if ( (v28 & 0x80u) != 0LL )
                    v28 = *(_QWORD *)(v15 + 8);
                v22 = 1LL;
//                v29 = std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::erase(v15, v28 - 1, 1LL);
//                std::__1::basic_string<char,std::__1::char_traits<char>,std::__1::allocator<char>>::operator=(v15, v29);
            }
        }
        
        
        
        
        
        
    }
    
}







