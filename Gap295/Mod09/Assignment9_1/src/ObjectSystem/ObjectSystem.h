// ObjectSystem.h
#pragma once
#include <string>
#include <vector>
#include <optional>

class GameObject
{
    std::string m_name;
    float m_x, m_y, m_z, m_width, m_height;

public:
    explicit GameObject(const char* name, float x, float y, float z, float width, float height);

    // default copy/move constructors & assignment operators
    GameObject(const GameObject&) = default;
    GameObject& operator=(const GameObject&) = default;
    GameObject(GameObject&&) = default;
    GameObject& operator=(GameObject&&) = default;

    void Draw() const;
};


class ObjectSystem
{
    const size_t m_maxObjectCount;
    size_t m_currentIndex;

    GameObject* const m_pBuffer;
public:
    explicit ObjectSystem(size_t maxObjectCount);  // TODO: Fix me
    ~ObjectSystem();

    // TODO: Implement these
    void AddGameObject(const char* name, float x, float y, float z, float width, float height);
    void DestroyGameObject(size_t index);

    // TODO: Fix me
    void Draw() const;
};

