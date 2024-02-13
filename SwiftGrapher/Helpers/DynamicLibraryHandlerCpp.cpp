//
//  DynamicLibraryHandlerCpp.cpp
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/02/2024.
//

#include "DynamicLibraryHandlerCpp.hpp"

DynamicLibraryHandlerCppImpl::DynamicLibraryHandlerCppImpl(const char *libraryPath) {
    
    this->libraryPath = libraryPath;
    this->isClosed = false;
    this->libraryAddress = dlopen(libraryPath, RTLD_GLOBAL);
}

DynamicLibraryHandlerCppImpl::~DynamicLibraryHandlerCppImpl() {
    this->close();
}

void DynamicLibraryHandlerCppImpl::close() {
    if (isClosed) {
        return;
    }
    
    int result = dlclose(libraryAddress);
    if (result == 0) {
        isClosed = true;
        return;
    }
}

void* DynamicLibraryHandlerCppImpl::symbol(const char *name) {
    if (isClosed) {
        return nullptr;
    }
    
    return dlsym(libraryAddress, name);
}
