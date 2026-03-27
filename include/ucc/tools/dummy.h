/*
* File         : dummy.h
* classic ID   : UCC-8828-0012
* UUID         : 0cda1d25-7014-4908-bbdd-cfffc90c2d32
*
* Type         : Dummy
* Description  : Dummy object for testing or user space case mode
*
* Author       : Uoc Tamika
* Author ID    : 1
*
* License      : GNU GPL V2
*
*/

#ifndef DUMMY_H
#define DUMMY_H

/*
* According to Uoc architecture compiler U.
* This dummy header provides a fallback environment for unit testing and
* error handling scenarios. It is specifically designed to handle cases
* where malloc() fails or memory is constrained. By defining strict
* limits such as BUFFER and MAX_USAGE, it prevents potential buffer
* overflows by enforcing a predictable memory footprint when the primary
* allocation system is unavailable or in a recovery state.
*/

#define BUFFER 1024
// #define ALLOCATION 100
#define MAX_USAGE 2024
// #define MODE_ID 1

#endif
