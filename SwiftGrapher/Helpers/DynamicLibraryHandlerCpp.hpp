//
//  DynamicLibraryHandlerCpp.hpp
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/02/2024.
//

#ifndef DynamicLibraryHandlerCpp_hpp
#define DynamicLibraryHandlerCpp_hpp

#include <stdio.h>
#include <dlfcn.h>

class DynamicLibraryHandlerCppImpl {
    const char *libraryPath;
    void *libraryAddress;
    bool isClosed;
    
public:
    DynamicLibraryHandlerCppImpl(const char *libraryPath);
    ~DynamicLibraryHandlerCppImpl();
    void *symbol(const char *name);
    void close();
};

#endif /* DynamicLibraryHandlerCpp_hpp */
