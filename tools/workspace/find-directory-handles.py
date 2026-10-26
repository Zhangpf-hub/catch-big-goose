"""Read-only Windows handle diagnostic; never closes handles in other processes."""
import ctypes as C
from ctypes import wintypes as W
import json
import msvcrt
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
target = str(ROOT / 'projects/catch-big-goose-unity').lower()
K = C.WinDLL('kernel32', use_last_error=True)
N = C.WinDLL('ntdll')
K.OpenProcess.argtypes = [W.DWORD, W.BOOL, W.DWORD]
K.OpenProcess.restype = W.HANDLE
K.GetCurrentProcess.restype = W.HANDLE
K.DuplicateHandle.argtypes = [W.HANDLE, W.HANDLE, W.HANDLE, C.POINTER(W.HANDLE), W.DWORD, W.BOOL, W.DWORD]
K.GetFileType.argtypes = [W.HANDLE]
K.CloseHandle.argtypes = [W.HANDLE]
K.GetFinalPathNameByHandleW.argtypes = [W.HANDLE, W.LPWSTR, W.DWORD, W.DWORD]
N.NtQuerySystemInformation.argtypes = [W.ULONG, C.c_void_p, W.ULONG, C.POINTER(W.ULONG)]

class Entry(C.Structure):
    _fields_ = [('object', C.c_void_p), ('pid', C.c_size_t), ('handle', C.c_size_t),
                ('access', W.ULONG), ('trace', W.USHORT), ('type', W.USHORT),
                ('attributes', W.ULONG), ('reserved', W.ULONG)]

probe = open(__file__, 'rb')
own = msvcrt.get_osfhandle(probe.fileno())
size = 2 ** 20
while True:
    buf = C.create_string_buffer(size)
    needed = W.ULONG()
    status = N.NtQuerySystemInformation(64, buf, size, C.byref(needed))
    if status == 0:
        break
    if status & 0xffffffff != 0xc0000004:
        raise OSError(hex(status & 0xffffffff))
    size = max(size * 2, needed.value + 65536)
count = C.c_size_t.from_buffer(buf).value
entries = (Entry * count).from_buffer(buf, C.sizeof(C.c_size_t) * 2)
file_type = next(e.type for e in entries if e.pid == os.getpid() and e.handle == own)
processes = {}
text = C.create_unicode_buffer(32768)
results = []
for entry in entries:
    if entry.type != file_type or entry.pid in [0, 4, os.getpid()]:
        continue
    if entry.pid not in processes:
        processes[entry.pid] = K.OpenProcess(0x40, False, entry.pid)
    process = processes[entry.pid]
    if not process:
        continue
    duplicate = W.HANDLE()
    if not K.DuplicateHandle(process, W.HANDLE(entry.handle), K.GetCurrentProcess(), C.byref(duplicate), 0, False, 2):
        continue
    try:
        if K.GetFileType(duplicate) != 1:
            continue
        length = K.GetFinalPathNameByHandleW(duplicate, text, len(text), 0)
        path = text.value.removeprefix('\\\\?\\') if length else ''
        if path.lower() == target or path.lower().startswith(target + '\\'):
            record = dict(pid=entry.pid, handle=entry.handle, path=path)
            results.append(record)
            print(json.dumps(record, ensure_ascii=False), flush=True)
    finally:
        K.CloseHandle(duplicate)
for process in processes.values():
    if process:
        K.CloseHandle(process)
probe.close()
print('Matching file/directory handles:', len(results), flush=True)
