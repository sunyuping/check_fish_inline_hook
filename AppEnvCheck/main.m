//
//  main.m
//  AppEnvCheck
//
//  Created by liaogang on 2018/9/30.
//  Copyright © 2018年 liaogang. All rights reserved.
//

#import "fishHookCheck.h"
#import "inlineHookCheck.h"
#import "uncacheModules.h"


int main(int argc, char * argv[]) {
    
    test_fish_hook();
    
    test_inline_hook_check();
    
    getAllUncachedModules();
    
}
