#+private package
package lib

import "base:intrinsics"
import "base:runtime"
import "core:fmt"

// constants
INVALID_HANDLE :: HANDLE(~uintptr(0))
INFINITE :: max(u32)

WAIT_OBJECT_0: DWORD : 0x000
WAIT_TIMEOUT: DWORD : 0x102
WAIT_FAILED: DWORD : max(u32)

CP_UTF8 :: 65001
WC_ERR_INVALID_CHARS :: 0x80
MB_ERR_INVALID_CHARS :: 0x08

WT_EXECUTEONLYONCE :: 0x8
TF_DISCONNECT :: 0x1
TF_REUSE_SOCKET :: 0x2

// types
ULONG_PTR :: uintptr
HANDLE :: distinct rawptr
CSTR :: [^]byte
CWSTR :: [^]u16

BOOL :: b32
BYTE :: u8
WORD :: u16
DWORD :: u32
QWORD :: u64
/* c types */
SHORT :: i16
USHORT :: u16
LONG :: i32
ULONG :: u32
LONGLONG :: i64
ULONGLONG :: u64

INT :: i32
UINT :: u32
/* -c types */
LARGE_INTEGER :: LONGLONG

GUID :: struct {
	Data1: DWORD,
	Data2: WORD,
	Data3: WORD,
	Data4: [8]BYTE,
}
OVERLAPPED :: struct {
	Internal:     ^ULONG,
	InternalHigh: ^ULONG,
	using _:      struct #raw_union {
		using _: struct {
			Offset:     DWORD,
			OffsetHigh: DWORD,
		},
		Pointer: rawptr,
	},
	hEvent:       HANDLE,
}
OVERLAPPED_COMPLETION_ROUTINE :: proc(
	error_code, bytes_transferred: DWORD,
	lpOverlapped: ^OVERLAPPED,
)
WAITORTIMERCALLBACK :: proc "std" (user_ptr: rawptr, TimerOrWaitFired: BOOL)

// Kernel32.lib procs
foreign import kernel32 "system:Kernel32.lib"
@(default_calling_convention = "c")
foreign kernel32 {
	// common procs
	WideCharToMultiByte :: proc(CodePage: UINT, dwFlags: DWORD, lpWideCharStr: CWSTR, cchWideChar: INT, lpMultiByteStr: CSTR, cbMultiByte: INT, lpDefaultChar: CSTR, lpUsedDefaultChar: ^BOOL) -> INT ---
	MultiByteToWideChar :: proc(CodePage: UINT, dwFlags: DWORD, lpMultiByteStr: CSTR, cbMultiByte: INT, lpWideCharStr: CWSTR, cchWideChar: INT) -> INT ---
	GetLastError :: proc() -> DWORD ---
	CreateEventW :: proc(attributes: ^SECURITY_ATTRIBUTES, manual_reset: BOOL, initial_state: BOOL, name: CWSTR) -> HANDLE ---
	ResetEvent :: proc(handle: HANDLE) -> BOOL ---
	WaitForSingleObject :: proc(handle: HANDLE, millis: DWORD) -> DWORD ---
	GetOverlappedResult :: proc(handle: HANDLE, overlapped: ^OVERLAPPED, bytes_transferred: ^DWORD, wait: BOOL) -> BOOL ---
	CloseHandle :: proc(handle: HANDLE) -> BOOL ---
	// process procs
	GetCommandLineW :: proc() -> CWSTR ---
	ExitProcess :: proc(uExitCode: UINT) ---
	// IOCP procs
	CreateIoCompletionPort :: proc(file: HANDLE, ExistingCompletionPort: HANDLE, CompletionKey: ULONG_PTR, NumberOfConcurrentThreads: DWORD) -> HANDLE ---
	GetQueuedCompletionStatus :: proc(iocp: HANDLE, bytes_transferred: ^DWORD, user_ptr: ^rawptr, overlapped: ^^OVERLAPPED, millis: DWORD) -> BOOL ---
	CreateTimerQueueTimer :: proc(timer: ^HANDLE, timer_queue: HANDLE, callback: WAITORTIMERCALLBACK, user_ptr: rawptr, timeout_ms, period_ms: DWORD, flags: ULONG) -> BOOL ---
	DeleteTimerQueueTimer :: proc(timer_queue: HANDLE, timer: HANDLE, event: HANDLE) ---
	CancelIoEx :: proc(handle: HANDLE, overlapped: ^OVERLAPPED) -> BOOL ---
}

// helper procs
@(private = "file")
_tprint_cwstr :: proc(cwstr: CWSTR, wlen := -1, allocator := context.temp_allocator) -> string {
	wlen_i32 := i32(wlen)
	assert(int(wlen_i32) == wlen)

	if intrinsics.expect(wlen_i32 == 0, false) {return ""}

	cstr_len := WideCharToMultiByte(
		CP_UTF8,
		WC_ERR_INVALID_CHARS,
		cwstr,
		wlen_i32,
		nil,
		0,
		nil,
		nil,
	)
	/* NOTE: Windows can return 0 if wlen_i32 == 0, otherwise it counts the null terminator and thus returns >0 */
	str_len := cstr_len - (wlen == -1 ? 1 : 0)
	if intrinsics.expect(str_len == 0, false) {return ""}

	str_buf, err := make([]byte, cstr_len, allocator = allocator)
	assert(err == nil)
	written_bytes := WideCharToMultiByte(
		CP_UTF8,
		WC_ERR_INVALID_CHARS,
		cwstr,
		wlen_i32,
		&str_buf[0],
		cstr_len,
		nil,
		nil,
	)
	assert(written_bytes == cstr_len)
	return transmute(string)(str_buf[:str_len])
}
@(private = "file")
_tprint_string16 :: proc(wstr: string16, allocator := context.temp_allocator) -> string {
	return _tprint_cwstr(raw_data(wstr), len(wstr), allocator = allocator)
}
_tprint_wstring :: proc {
	_tprint_cwstr,
	_tprint_string16,
}
_tprint_string_as_wstring :: proc(str: string, allocator := context.temp_allocator) -> CWSTR {
	str_len := len(str)
	str_len_i32 := i32(str_len)
	assert(int(str_len_i32) == str_len)

	wlen := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, raw_data(str), str_len_i32, nil, 0)
	assert(wlen != 0)
	cwlen := wlen + 1
	cwstr_buf := make([]u16, cwlen, allocator = allocator)

	written_chars := MultiByteToWideChar(
		CP_UTF8,
		MB_ERR_INVALID_CHARS,
		raw_data(str),
		str_len_i32,
		&cwstr_buf[0],
		cwlen,
	)
	assert(written_chars == wlen)
	return &cwstr_buf[0]
}

// path constants
FILE_LIST_DIRECTORY: DWORD : 0x00000001

GENERIC_READ: DWORD : 0x80000000
GENERIC_WRITE: DWORD : 0x40000000
GENERIC_EXECUTE: DWORD : 0x20000000
GENERIC_ALL: DWORD : 0x10000000

FILE_SHARE_READ: DWORD : 0x00000001
FILE_SHARE_WRITE: DWORD : 0x00000002
FILE_SHARE_DELETE: DWORD : 0x00000004

F_CREATE: DWORD : 1
F_CREATE_OR_OPEN: DWORD : 4
F_CREATE_OR_OPEN_AND_TRUNCATE: DWORD : 2
F_OPEN: DWORD : 3
F_OPEN_AND_TRUNCATE: DWORD : 5

FILE_ATTRIBUTE_DIRECTORY: DWORD : 0x00000010
FILE_ATTRIBUTE_NORMAL: DWORD : 0x00000080

FILE_FLAG_WRITE_THROUGH: DWORD : 0x80000000
FILE_FLAG_OVERLAPPED: DWORD : 0x40000000
FILE_FLAG_NO_BUFFERING: DWORD : 0x20000000
FILE_FLAG_RANDOM_ACCESS: DWORD : 0x10000000
FILE_FLAG_SEQUENTIAL_SCAN: DWORD : 0x08000000
FILE_FLAG_BACKUP_SEMANTICS: DWORD : 0x02000000

FILE_NOTIFY_CHANGE_FILE_NAME :: 0x00000001
FILE_NOTIFY_CHANGE_DIR_NAME :: 0x00000002
FILE_NOTIFY_CHANGE_ATTRIBUTES :: 0x00000004
FILE_NOTIFY_CHANGE_SIZE :: 0x00000008
FILE_NOTIFY_CHANGE_LAST_WRITE :: 0x00000010
FILE_NOTIFY_CHANGE_LAST_ACCESS :: 0x00000020
FILE_NOTIFY_CHANGE_CREATION :: 0x00000040
FILE_NOTIFY_CHANGE_SECURITY :: 0x00000100

/* NOTE: *NOT* the max path on windows anymore, but half the apis don't support paths above this... */
MAX_PATH :: 260

// file types
/*
FILETIME :: struct #align (4) {
	value: u64le,
}
*/
FILETIME :: struct {
	dwLowDateTime:  DWORD,
	dwHighDateTime: DWORD,
}
SECURITY_DESCRIPTOR :: struct {
	/*
	Revision, Sbz1: BYTE,
	Control:        SECURITY_DESCRIPTOR_CONTROL,
	Owner, Group:   PSID,
	Sacl, Dacl:     PACL,
	*/
}
SECURITY_ATTRIBUTES :: struct {
	nLength:              DWORD,
	lpSecurityDescriptor: ^SECURITY_DESCRIPTOR,
	bInheritHandle:       BOOL,
}

// dir types
FindFile :: distinct HANDLE
FILE_NOTIFY_INFORMATION :: struct {
	next_entry_offset: DWORD,
	action:            DWORD,
	file_name_length:  DWORD,
	file_name:         [1]u16,
}
WIN32_FIND_DATAW :: struct {
	dwFileAttributes:   DWORD,
	ftCreationTime:     FILETIME,
	ftLastAccessTime:   FILETIME,
	ftLastWriteTime:    FILETIME,
	nFileSizeHigh:      DWORD,
	nFileSizeLow:       DWORD,
	dwReserved0:        DWORD,
	dwReserved1:        DWORD,
	/* worst api design ever? */
	cFileName:          [MAX_PATH]u16,
	cAlternateFileName: [14]u16,
	/* Obsolete. Do not use */
	dwFileType:         DWORD,
	/* Obsolete. Do not use */
	dwCreatorType:      DWORD,
	/* Obsolete. Do not use */
	wFinderFlags:       WORD,
}

// path procs
@(default_calling_convention = "c")
foreign kernel32 {
	// file procs
	CreateFileW :: proc(lpFileName: CWSTR, dwDesiredAccess: DWORD, dwShareMode: DWORD, lpSecurityAttributes: ^SECURITY_ATTRIBUTES, dwCreationDisposition: DWORD, dwFlagsAndAttributes: DWORD, hTemplateFile: HANDLE) -> HANDLE ---
	GetFileSizeEx :: proc(file: FileHandle, file_size: ^LARGE_INTEGER) -> BOOL ---
	ReadFile :: proc(file: FileHandle, buffer: [^]byte, bytes_to_read: DWORD, bytes_read: ^DWORD, overlapped: ^OVERLAPPED) -> BOOL ---
	WriteFile :: proc(file: FileHandle, buffer: [^]byte, bytes_to_write: DWORD, bytes_written: ^DWORD, overlapped: ^OVERLAPPED) -> BOOL ---
	FlushFileBuffers :: proc(file: FileHandle) -> BOOL ---
	// dir procs
	ReadDirectoryChangesW :: proc(dir: DirHandle, buffer: [^]byte, buffer_len: DWORD, subtree: BOOL, filter: DWORD, bytes_returned: ^DWORD, overlapped: ^OVERLAPPED, on_complete: ^OVERLAPPED_COMPLETION_ROUTINE) -> BOOL ---
	FindFirstFileW :: proc(file_name: CWSTR, data: ^WIN32_FIND_DATAW) -> FindFile ---
	FindNextFileW :: proc(find: FindFile, data: ^WIN32_FIND_DATAW) -> BOOL ---
	FindClose :: proc(find: FindFile) -> BOOL ---
}
