// ObjectSystem.cpp
#include "ObjectSystem.h"
#include <iostream>
#include <assert.h>

//---------------------------------------------------------------------------------------------------------------------
// Game Objects
//---------------------------------------------------------------------------------------------------------------------
GameObject::GameObject(const char* name, float x, float y, float z, float width, float height)
    : m_name(name)
    , m_x(x)
    , m_y(y)
    , m_z(z)
    , m_width(width)
    , m_height(height)

{
    //
}

void GameObject::Draw() const
{
    std::cout << "[" << m_name << "] x: " << m_x << "; y: " << m_y << "; z: " << m_z << "; width: " << m_width << " ; height: " << m_height << std::endl;
}


//---------------------------------------------------------------------------------------------------------------------
// Object System
//---------------------------------------------------------------------------------------------------------------------
ObjectSystem::ObjectSystem(size_t maxObjectCount)
    : m_maxObjectCount(maxObjectCount)
    , m_currentIndex(0)
    , m_pBuffer(reinterpret_cast<GameObject*>(new std::byte[m_maxObjectCount * sizeof(GameObject)]))
{
}

ObjectSystem::~ObjectSystem()
{
    for (size_t i = 0; i < m_currentIndex; ++i)
    {
        m_pBuffer[i].~GameObject();
    }
    delete[] reinterpret_cast<std::byte*>(m_pBuffer);
}

void ObjectSystem::AddGameObject(const char* name, float x, float y, float z, float width, float height)
{
    assert(m_currentIndex < m_maxObjectCount);

    new (m_pBuffer + m_currentIndex) GameObject(name, x, y, z, width, height);
    ++m_currentIndex;
}

void ObjectSystem::DestroyGameObject(size_t index)
{
    assert(index < m_currentIndex);

    m_pBuffer[index].~GameObject();

    if (index != m_currentIndex - 1)
        memmove(m_pBuffer + index, m_pBuffer + index + 1, sizeof(GameObject) * (m_currentIndex - index - 1));

    --m_currentIndex;
}

void ObjectSystem::Draw() const
{
    for (size_t i = 0; i < m_currentIndex; ++i)
    {
        m_pBuffer[i].Draw();
    }
    std::cout << std::endl;
}
