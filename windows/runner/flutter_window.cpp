#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetupMethodChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  return true;
}

void FlutterWindow::SetupMethodChannel() {
  flutter::MethodChannel<flutter::EncodableValue> channel(
      flutter_controller_->engine()->messenger(), "com.core.manager/version",
      &flutter::StandardMethodCodec::GetInstance());

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getVersionCode") {
          result->Success(flutter::EncodableValue(GetVersionCode()));
        } else if (call.method_name() == "getVersionName") {
          result->Success(flutter::EncodableValue(GetVersionName()));
        } else {
          result->NotImplemented();
        }
      });
}

std::string FlutterWindow::GetVersionCode() {
  // Get version from Windows resource file
  TCHAR filename[MAX_PATH];
  GetModuleFileName(nullptr, filename, MAX_PATH);

  DWORD handle = 0;
  DWORD size = GetFileVersionInfoSize(filename, &handle);
  if (size == 0) {
    return "Unknown";
  }

  std::vector<BYTE> buffer(size);
  if (!GetFileVersionInfo(filename, handle, size, buffer.data())) {
    return "Unknown";
  }

  VS_FIXEDFILEINFO* fileInfo = nullptr;
  UINT len = 0;
  if (VerQueryValue(buffer.data(), TEXT("\\"), (LPVOID*)&fileInfo, &len)) {
    DWORD versionLS = fileInfo->dwFileVersionLS;
    int build = LOWORD(versionLS);
    return std::to_string(build);
  }

  return "Unknown";
}

std::string FlutterWindow::GetVersionName() {
  // Get version from Windows resource file
  TCHAR filename[MAX_PATH];
  GetModuleFileName(nullptr, filename, MAX_PATH);

  DWORD handle;
  DWORD size = GetFileVersionInfoSize(filename, &handle);
  if (size == 0) {
    return "Unknown";
  }

  std::vector<BYTE> buffer(size);
  if (!GetFileVersionInfo(filename, handle, size, buffer.data())) {
    return "Unknown";
  }

  VS_FIXEDFILEINFO* fileInfo = nullptr;
  UINT len = 0;
  if (VerQueryValue(buffer.data(), TEXT("\\"), (LPVOID*)&fileInfo, &len)) {
    DWORD versionMS = fileInfo->dwFileVersionMS;
    DWORD versionLS = fileInfo->dwFileVersionLS;
    
    int major = HIWORD(versionMS);
    int minor = LOWORD(versionMS);
    int patch = HIWORD(versionLS);
    
    return std::to_string(major) + "." + std::to_string(minor) + "." + std::to_string(patch);
  }

  return "Unknown";
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
