module("execute", package.seeall)
local _llthreads = require("llthreads")
local thread_pool = {}
local command_args = {}
local command_times = {}
local result_callbacks = {}
local timeouts = {}
local timeout_callbacks = {}
local execute_thread_code = string.dump(function(arg)
  local ffi = require("ffi")
  ffi.cdef[[typedef void* HANDLE;typedef uint32_t DWORD;typedef uint16_t WORD;typedef int BOOL;typedef struct{DWORD cb;char* lpReserved;char* lpDesktop;char* lpTitle;DWORD dwX;DWORD dwY;DWORD dwXSize;DWORD dwYSize;DWORD dwXCountChars;DWORD dwYCountChars;DWORD dwFillAttribute;DWORD dwFlags;WORD wShowWindow;WORD cbReserved2;void* lpReserved2;HANDLE hStdInput;HANDLE hStdOutput;HANDLE hStdError;}STARTUPINFOA;typedef struct{HANDLE hProcess;HANDLE hThread;DWORD dwProcessId;DWORD dwThreadId;}PROCESS_INFORMATION;typedef struct{DWORD nLength;void* lpSecurityDescriptor;BOOL bInheritHandle;}SECURITY_ATTRIBUTES;BOOL CreateProcessA(const char*,char*,SECURITY_ATTRIBUTES*,SECURITY_ATTRIBUTES*,BOOL,DWORD,void*,const char*,STARTUPINFOA*,PROCESS_INFORMATION*);BOOL CreatePipe(HANDLE*,HANDLE*,SECURITY_ATTRIBUTES*,DWORD);BOOL ReadFile(HANDLE,void*,DWORD,DWORD*,void*);BOOL CloseHandle(HANDLE);DWORD WaitForSingleObject(HANDLE,DWORD);BOOL GetExitCodeProcess(HANDLE,DWORD*);]]
  local k32=ffi.load("kernel32")
  local out={}
  local sa=ffi.new("SECURITY_ATTRIBUTES")
  sa.nLength=ffi.sizeof("SECURITY_ATTRIBUTES")
  sa.bInheritHandle=1
  local hR=ffi.new("HANDLE[1]")
  local hW=ffi.new("HANDLE[1]")
  if k32.CreatePipe(hR,hW,sa,0)==0 then return false,out,"Pipe failed",-1 end
  local si=ffi.new("STARTUPINFOA")
  si.cb=ffi.sizeof("STARTUPINFOA")
  si.dwFlags=0x00000100
  si.hStdOutput=hW[0]
  si.hStdError=hW[0]
  local pi=ffi.new("PROCESS_INFORMATION")
  local flags=arg.hide_window and 0x08000000 or 0
  local cb=ffi.new("char[?]",#arg.cmd+1)
  ffi.copy(cb,arg.cmd)
  if k32.CreateProcessA(nil,cb,nil,nil,1,flags,nil,arg.working_dir,si,pi)==0 then
    k32.CloseHandle(hR[0])
    k32.CloseHandle(hW[0])
    return false,out,"Process failed",-1
  end
  k32.CloseHandle(hW[0])
  local buf=ffi.new("char[4096]")
  local br=ffi.new("DWORD[1]")
  local cur=""
  while k32.ReadFile(hR[0],buf,4096,br,nil)~=0 and br[0]>0 do
    cur=cur..ffi.string(buf,br[0])
    while true do
      local p=cur:find("[\r\n]")
      if not p then break end
      local ln=cur:sub(1,p-1)
      if #ln>0 then table.insert(out,ln)end
      cur=cur:sub(p+1)
      if cur:sub(1,1):match("[\r\n]")then cur=cur:sub(2)end
    end
  end
  if #cur>0 then table.insert(out,cur)end
  k32.WaitForSingleObject(pi.hProcess,0xFFFFFFFF)
  local ec=ffi.new("DWORD[1]")
  k32.GetExitCodeProcess(pi.hProcess,ec)
  k32.CloseHandle(hR[0])
  k32.CloseHandle(pi.hProcess)
  k32.CloseHandle(pi.hThread)
  return true,out,nil,ec[0]
end)
function default_timeout_callback(cmd,timeout)
  Note("Command ["..cmd.."] timed out after "..tostring(timeout).."s")
end
function __checkCompletionFor(thread_id)
  if thread_pool[thread_id]:alive()then
    if os.time()-command_times[thread_id]>timeouts[thread_id]then
      local tc=timeout_callbacks[thread_id]
      local cmd=command_args[thread_id]
      local to=timeouts[thread_id]
      thread_pool[thread_id]=nil
      command_times[thread_id]=nil
      result_callbacks[thread_id]=nil
      timeout_callbacks[thread_id]=nil
      timeouts[thread_id]=nil
      command_args[thread_id]=nil
      if tc then tc(cmd,to)else default_timeout_callback(cmd,to)end
    else
      DoAfterSpecial(0.2,"execute.__checkCompletionFor('"..thread_id.."')",sendto.script)
    end
  else
    local thread_success,success,output_lines,error_message,exit_code=thread_pool[thread_id]:join()
    local cb=result_callbacks[thread_id]
    result_callbacks[thread_id]=nil
    timeout_callbacks[thread_id]=nil
    thread_pool[thread_id]=nil
    command_times[thread_id]=nil
    timeouts[thread_id]=nil
    command_args[thread_id]=nil
    if cb then
      if success then
        cb(true,output_lines,exit_code,error_message)
      else
        cb(false,output_lines or{},exit_code,error_message)
      end
    end
  end
end
function doAsyncExecute(cmd,result_callback,options)
  options=options or{}
  local hide_window=options.hide_window
  if hide_window==nil then hide_window=true end
  local working_dir=options.working_dir
  local timeout_after=options.timeout or 60
  local timeout_callback=options.timeout_callback
  assert(type(cmd)=="string")
  assert(type(result_callback)=="function")
  local thread_id=tostring(GetUniqueNumber())
  local thread=_llthreads.new(execute_thread_code,{cmd=cmd,hide_window=hide_window,working_dir=working_dir})
  thread:start()
  command_args[thread_id]=cmd
  timeouts[thread_id]=timeout_after
  thread_pool[thread_id]=thread
  command_times[thread_id]=os.time()
  result_callbacks[thread_id]=result_callback
  timeout_callbacks[thread_id]=timeout_callback
  __checkCompletionFor(thread_id)
end
