#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

LRESULT CALLBACK MyWndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
static WNDPROC originalWndProc = nullptr; // Store original window procedure

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

       // Create a unique mutex name (replace with your app's GUID/name)
  HANDLE mutex = CreateMutexW(nullptr, TRUE, L"ultra_pos_9F4A8B2E-1234-5678-9012-ABCDEF123456");
  
  // Check if another instance exists
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    MessageBoxW(nullptr, 
                L"Core Manager is already running!", 
                L"Multiple Instances Detected", 
                MB_OK | MB_ICONERROR);
    ReleaseMutex(mutex);
    CloseHandle(mutex);
    return EXIT_FAILURE;  // Exit immediately
  }                  
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"ultra_pos", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);
   // ======== CRITICAL ADDITION STARTS HERE ========
   // Replace the window subclassing code with:
    HWND hwnd = window.GetNativeWindow();
    if (hwnd) {
        originalWndProc = (WNDPROC)GetWindowLongPtr(hwnd, GWLP_WNDPROC);
        SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)MyWndProc);
    }
    // ======== CRITICAL ADDITION ENDS HERE ========

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

LRESULT CALLBACK MyWndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
    static bool isClosing = false;

    if (message == WM_CLOSE) {
        if (isClosing) return 0;

        int result = MessageBoxW(hwnd,
            L"Are you sure you want to close Core Manager?",
            L"Confirm Exit",
            MB_YESNO | MB_ICONQUESTION);

        if (result == IDNO) return 0;

        isClosing = true;

        
        // Post message to initiate clean shutdown
        PostMessage(hwnd, WM_USER+1, 0, 0);
        return 0;
    }
    else if (message == WM_USER+1) {
        // Final destruction after message loop processes
        DestroyWindow(hwnd);
    }
    else if (message == WM_DESTROY) {
        // Allow Flutter to clean up before exit
        PostQuitMessage(0);
    }
    
    return CallWindowProc(originalWndProc, hwnd, message, wParam, lParam);
}