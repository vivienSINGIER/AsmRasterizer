#include <iostream>
#include <windows.h>

struct alignas(16) Vect3 { float x, y, z, w; };
struct alignas(16) Triangle { Vect3 a, b, c; char color; };
struct Ray { Vect3 origin, dir; };

extern "C" 
{
    void asm_print(const char* str, int64_t _length);
    void asm_clear();

    int  asm_is_key_down(int _keyCode);
    
    void Draw();
    void Run();

    // MATH
    float Intersect(const Triangle* _tri, const Ray* _ray);
}

HANDLE GetRealConsole()                                                                                                                                                                                                           
{                 
    FreeConsole();
    AllocConsole();                                                                                                                                                                                                           
                                                                                                                                                                                                                                
    HANDLE h = CreateFileA("CONOUT$", GENERIC_READ | GENERIC_WRITE,                                                                                                                                                               
                         FILE_SHARE_READ | FILE_SHARE_WRITE,                                                                                                                                                                    
                         nullptr, OPEN_EXISTING, 0, nullptr);                                                                                                                                                                   
    if (h == INVALID_HANDLE_VALUE)                                                                                                                                                                                                
        return nullptr;                                                                                                                                                                                                           
                                                                                                                                                                                                                                
    SetStdHandle(STD_OUTPUT_HANDLE, h);                                                                                                                                                   
    return h;                                                                                                                                                                                                                     
}  

bool EnableVT()                                                                                                                                                                                                                   
{                                                                                                                                                                                                                                 
    HANDLE h = GetRealConsole();                                                                                                                                                                                                  
    DWORD mode = 0;                                                                                                                                                                                                               
    if (!h || !GetConsoleMode(h, &mode))                                                                                                                                                                                          
        return false;                                                                                                                                                                                                             
    return SetConsoleMode(h, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING) != 0;                                                                                                                                                  
}  

int main() {
    if (EnableVT() == false)
        std::cout << "Couldn't set console mode." << std::endl;

    Run();
    
    return 0;
}
