// Main.cpp
#include <vld.h>
#include <ctime>
#include <iostream>
#include "ObjectSystem/ObjectSystem.h"

//---------------------------------------------------------------------------------------------------------------------
// Assignment 9.1
// 
// The lead engineer has assigned you the task of fixing and finishing the implementation of this object system.  She 
// initially gave it to a junior engineer, but they ran into tons of problems and weren't able to finish it.  Your 
// job is to complete the implementation.
// 
// The current idea for the design is as follows:
// 1) The ObjectSystem's constructor takes in a size_t that represents the number of objects we're allowed to have.
// 2) In the constructor, it news up an array of those game objects.  The idea is to keep track of which game objects 
//    are active and which are aren't.
// 3) Unfortunately, this doesn't work.  GameObject has no default constructor.  Besides, GameObject's may need to 
//    do a bunch of work in the constructor to load up their texture, so this wouldn't be viable anyway.
// 
// Your task is as follows:
// 1) Implement ObjectSystem::AddGameObject() and ObjectSystem::DestroyGameObject().
// 2) Make sure ObjectSystem::Draw() works.  It will likely end up changing.
// 
// You have the following constraints:
// 1) You may NOT change GameObject in any way.  This includes adding a default constructor.
// 2) You may ONLY call new and delete ONCE each, and ONLY from the ObjectSystem constructor and destructor, 
//    respectively.
// 3) You MUST construct and destruct objects as they are created and destroyed.
// 
// In addition, I've been seeing a bit of laziness lately, so I am imposing the following additional requirements:
// 1) You must have ZERO memory leaks.  You will lose a full letter grade for EACH memory leak.
// 2) Your project MUST build in Debug and Release in BOTH x86 and x64.  If any of these configurations don't build, 
//    the assignment will be treated as if it doesn't compile and you will receive a 0.
// 3) You must have ZERO warnings.  You will lose a full letter grade for EACH warning.  Make sure you do a clean 
//    rebuild before submitting your work.  Don't just hit build, do a clean rebuild.  Ask me if you don't know what 
//    that is.  Important: Check all four build configurations!!  You might have a warning in x64 but not x86.
//---------------------------------------------------------------------------------------------------------------------


int main()
{
    // Note: The Draw() calls are commented out below because they currently crash the project.

    ObjectSystem objectSystem(15);

    objectSystem.AddGameObject("Cat", 10, 11, 12, 13, 14);
    objectSystem.AddGameObject("Dog", 100, 110, 120, 130, 140);
    objectSystem.AddGameObject("Rat", 1000, 1100, 1200, 1300, 1400);
    objectSystem.Draw();

    objectSystem.DestroyGameObject(1);  // dog should be gone
    objectSystem.Draw();

    objectSystem.AddGameObject("Bird", 10000, 11000, 12000, 13000, 14000);
    objectSystem.Draw();

    system("pause");
    return 0;
}
