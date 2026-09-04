#!/usr/bin/env pwsh -NoProfile -File
param([switch]$Force)

$data = $null
if ([Console]::IsInputRedirected) {
    $input_json = [Console]::In.ReadToEnd()
    if ($input_json) { $data = $input_json | ConvertFrom-Json }
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [StructLayout(LayoutKind.Sequential)]
    public struct FLASHWINFO {
        public uint cbSize;
        public IntPtr hwnd;
        public uint dwFlags;
        public uint uCount;
        public uint dwTimeout;
    }
    // dwFlags: FLASHW_ALL = 3, FLASHW_TIMERNOFG = 12
    [DllImport("user32.dll")] public static extern bool FlashWindowEx(ref FLASHWINFO pwfi);

    public static void Flash(IntPtr hwnd) {
        var fi = new FLASHWINFO();
        fi.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(fi);
        fi.hwnd = hwnd;
        fi.dwFlags = 3 | 12; // FLASHW_ALL | FLASHW_TIMERNOFG
        fi.uCount = 3;
        fi.dwTimeout = 0;
        FlashWindowEx(ref fi);
    }
}
"@

# Walk the process tree to find the nearest ancestor with a visible main window
function Get-AncestorHwnd {
    $pid_ = $PID
    while ($pid_ -gt 0) {
        $proc = Get-Process -Id $pid_ -ErrorAction SilentlyContinue
        if (-not $proc) { break }
        if ($proc.MainWindowHandle -ne [IntPtr]::Zero) { return $proc.MainWindowHandle }
        $parentId = (Get-CimInstance Win32_Process -Filter "ProcessId=$pid_" -ErrorAction SilentlyContinue).ParentProcessId
        if (-not $parentId -or $parentId -eq $pid_) { break }
        $pid_ = $parentId
    }
    return [IntPtr]::Zero
}

$fgHwnd = [Win32]::GetForegroundWindow()
$ancestorHwnd = Get-AncestorHwnd

$isForeground = $ancestorHwnd -ne [IntPtr]::Zero -and $ancestorHwnd -eq $fgHwnd

if (-not $Force -and $isForeground) {
    # Terminal is already in the foreground — nothing to do
    exit 0
}

# Flash the taskbar if the terminal is in the background
if ($ancestorHwnd -ne [IntPtr]::Zero -and -not $isForeground) {
    [Win32]::Flash($ancestorHwnd)
}

$aumid = "ClaudeCode.Notifications"

$eventDefaults = @{
    "StopFailure"               = @{ title = "Turn failed";        message = "Claude hit an API error" }
    "SubagentStop"              = @{ title = "Subagent done";      message = "A subagent finished" }
    "agent_needs_input"         = @{ title = "Agent waiting";      message = "A background agent needs your input" }
    "agent_completed"           = @{ title = "Agent finished";     message = "A background agent completed" }
    "elicitation_dialog"        = @{ title = "Input needed";       message = "An MCP server needs your input" }
    "elicitation_url_dialog"    = @{ title = "Browser needed";     message = "An MCP server needs you to open a URL" }
    "quota_auto_resume_stale"   = @{ title = "Usage limit";        message = "Press Enter to continue after the usage limit reset" }
    "quota_auto_resume_disabled"= @{ title = "Task paused";        message = "Auto-resume after the usage limit was cancelled" }
}
$hookEvent      = $data.hook_event_name
$defaults       = $eventDefaults[$hookEvent]
$defaultTitle   = if ($defaults) { $defaults.title }   else { "Claude Code" }
$defaultMessage = if ($defaults) { $defaults.message } else { "Needs your attention" }

$robot   = [char]::ConvertFromUtf32(0x1F916)
$title   = if ($data.title)   { "$robot $($data.title)" } else { "$robot $defaultTitle" }
$message = if ($data.message) { $data.message }           else { $defaultMessage }

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$xml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$([System.Security.SecurityElement]::Escape($title))</text>
      <text>$([System.Security.SecurityElement]::Escape($message))</text>
    </binding>
  </visual>
</toast>
"@

$doc = [Windows.Data.Xml.Dom.XmlDocument]::new()
$doc.LoadXml($xml)

$toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($aumid).Show($toast)

exit 0
