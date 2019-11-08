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
    : m_pBuffer(reinterpret_cast<GameObject*>(new std::byte[maxObjectCount * sizeof(GameObject)]))
    , m_pBufferEnd(m_pBuffer + maxObjectCount)
    , m_pBufferCurrent(m_pBuffer)
{
}

ObjectSystem::~ObjectSystem()
{
    for (GameObject* pIt = m_pBuffer; pIt != m_pBufferCurrent; ++pIt)
    {
        pIt->~GameObject();
    }
    delete[] reinterpret_cast<std::byte*>(m_pBuffer);
}

void ObjectSystem::AddGameObject(const char* name, float x, float y, float z, float width, float height)
{
    assert(m_pBufferCurrent != m_pBufferEnd);

    new (m_pBufferCurrent) GameObject(name, x, y, z, width, height);
    ++m_pBufferCurrent;
}

void ObjectSystem::DestroyGameObject(size_t index)
{
    assert(m_pBufferCurrent > m_pBuffer && index < static_cast<size_t>(m_pBufferCurrent - m_pBuffer));

    m_pBuffer[index].~GameObject();

    if (index != m_pBufferCurrent - m_pBuffer - 1)
        memmove(m_pBuffer + index, m_pBuffer + index + 1, sizeof(GameObject) * (m_pBufferCurrent - m_pBuffer - index - 1));

    --m_pBufferCurrent;
}

void ObjectSystem::Draw() const
{
    for (const GameObject* pIt = m_pBuffer; pIt != m_pBufferCurrent; ++pIt)
    {
        pIt->Draw();
    }
    std::cout << std::endl;
}
