;/------------------
;|
;| BlueTooth.pbi
;| Module Version
;|
;| (c)HeX0R 2016
;| V1.02 [09.03.2016]
;|
;| MSDN Bluetooth-Reference:
;| http://msdn.microsoft.com/en-us/library/aa362930%28v=VS.85%29.aspx
;|
;| See also this thread to be informed, that microsofts
;| bluetooth-support is not the best at all: [This thread is in german language!]
;| http://www.purebasic.fr/german/viewtopic.php?f=6&t=23856
;|
;| So chances are good, that you won't scan any device with this include.
;| If you have no lock, blame M$ not me ;)
;|
;/------------------

DeclareModule BLUETOOTH
   
   EnableExplicit
   
   #BLUETOOTH_MAX_NAME_SIZE     = 248
   #ERROR_NOT_FOUND             = 1168
   
   ;The following structure is not really correct, but it works
   Structure BLUETOOTH_ADDRESS
      BTH_ADDR.l
      rgBytes.b[8]
   EndStructure
   
   
   ;36
   Structure BLUETOOTH_DEVICE_SEARCH_PARAMS
      dwSize.l
      fReturnAuthenticated.l
      fReturnRemembered.l
      fReturnUnknown.l
      fReturnConnected.l
      fIssueInquiry.l
      cTimeoutMultiplier.i
      hRadio.i
   EndStructure
   
   ;560
   Structure BLUETOOTH_DEVICE_INFO
      dwSize.l
      Address.BLUETOOTH_ADDRESS
      ulClassofDevice.l
      fConnected.l
      fRemembered.l
      fAuthenticated.l
      stLastSeen.SYSTEMTIME
      stLastUsed.SYSTEMTIME
      szName.w[#BLUETOOTH_MAX_NAME_SIZE]
   EndStructure
      
   
   Structure BLUETOOTH_FIND_RADIO_PARAMS
      dwSize.l
   EndStructure
   
   Structure BLUETOOTH_RADIO_INFO
      dwSize.l
      address.BLUETOOTH_ADDRESS
      szName.w[#BLUETOOTH_MAX_NAME_SIZE];
      ulClassofDevice.l
      lmpSubversion.w
      manufacturer.w
   EndStructure

   Declare InitBlueTooth()
   Declare ConnectLocal()
   Declare DisconnectLocal()
   Declare ScanDevices(SearchTime, IgnoreUnnamedDevices = #False)
   Declare CountFoundDevices()
   Declare.s GetDeviceName(Num.i)
   Declare.s GetDeviceAddress(Num)
   Declare GetDeviceTimeLastSeen(Num.i)
   Declare GetDeviceTimeLastUsed(Num.i)
   Declare RefreshDeviceInfo(Num.i)
   Declare IsDeviceConnected(Num)
   Declare IsDeviceAuthenticated(Num)
   Declare GetDeviceInfo(Num, *pbtdi.BLUETOOTH_DEVICE_INFO)
   Declare AuthenticateDevice(Num, Password.s = "")
   Declare AddSerialPortToDevice(Num, Mode)
   Declare RemoveDevice(Num)
   Declare GetLastError()
; Declare   DisconnectDevice(Num)
   
EndDeclareModule

Module BLUETOOTH

   Global Handle.i
   Global LastError.l
   Global NumDevices.i
   Global MaxDevices.i
   Global *Devices
   
   Prototype __BluetoothFindFirstDevice(*pbtsp, *pbtdi)
   Prototype __BluetoothFindNextDevice(hFind, *pbtdi)
   Prototype __BluetoothFindDeviceClose(hFind)
   Prototype __BluetoothFindFirstRadio(*pbtfrp, *phRadio)
   Prototype __BluetoothFindNextRadio(hFind, *phRadio)
   Prototype __BluetoothFindRadioClose(hFind)
   Prototype __BluetoothGetRadioInfo(hRadio, *pRadioInfo)
   Prototype __BluetoothGetDeviceInfo(hRadio, *pbtdi)
   Prototype __BluetoothDisplayDeviceProperties(hwndParent, *pbtdi)
   Prototype __BluetoothEnableDiscovery(hRadio, fEnabled)
   Prototype __BluetoothEnableIncomingConnections(hRadio, fEnabled)
   Prototype __BluetoothSelectDevices(*pbtsdp)
   Prototype __BluetoothIsConnectable(hRadio)
   Prototype __BluetoothIsDiscoverable(hRadio)
   Prototype __BluetoothSelectDevicesFree(*pbtsdp)
   Prototype __BluetoothAuthenticateDevice(hwndParent, hRadio, *pbtdi, *pszPasskey, ulPasskeyLength)
   Prototype __BluetoothSetServiceState(hRadio, *pbtdi, *pGuidService, dwServiceFlags.l)
   Prototype __BluetoothRemoveDevice(*pAddress)
   Prototype __BluetoothUpdateDeviceRecord(*pbtdi)
   
   Global BluetoothFindFirstDevice.          __BluetoothFindFirstDevice
   Global BluetoothFindNextDevice.           __BluetoothFindNextDevice
   Global BluetoothFindDeviceClose.          __BluetoothFindDeviceClose
   Global BluetoothFindFirstRadio.           __BluetoothFindFirstRadio
   Global BluetoothFindNextRadio.            __BluetoothFindNextRadio
   Global BluetoothFindRadioClose.           __BluetoothFindRadioClose
   Global BluetoothGetRadioInfo.             __BluetoothGetRadioInfo
   Global BluetoothGetDeviceInfo.            __BluetoothGetDeviceInfo
   Global BluetoothDisplayDeviceProperties.  __BluetoothDisplayDeviceProperties
   Global BluetoothEnableDiscovery.          __BluetoothEnableDiscovery
   Global BluetoothEnableIncomingConnections.__BluetoothEnableIncomingConnections
   Global BluetoothSelectDevices.            __BluetoothSelectDevices
   Global BluetoothIsConnectable.            __BluetoothIsConnectable
   Global BluetoothIsDiscoverable.           __BluetoothIsDiscoverable
   Global BluetoothSelectDevicesFree.        __BluetoothSelectDevicesFree
   Global BluetoothAuthenticateDevice.       __BluetoothAuthenticateDevice
   Global BluetoothSetServiceState.          __BluetoothSetServiceState
   Global BluetoothRemoveDevice.             __BluetoothRemoveDevice
   Global BluetoothUpdateDeviceRecord.       __BluetoothUpdateDeviceRecord
   Global Lib
   
   Procedure InitDll()
      
      Lib = OpenLibrary(#PB_Any, "bthprops.cpl")
      If Lib
         BluetoothFindFirstDevice           = GetFunction(Lib, "BluetoothFindFirstDevice")
         BluetoothFindNextDevice            = GetFunction(Lib, "BluetoothFindNextDevice")
         BluetoothFindDeviceClose           = GetFunction(Lib, "BluetoothFindDeviceClose")
         BluetoothFindFirstRadio            = GetFunction(Lib, "BluetoothFindFirstRadio")
         BluetoothFindNextRadio             = GetFunction(Lib, "BluetoothFindNextRadio")
         BluetoothFindRadioClose            = GetFunction(Lib, "BluetoothFindRadioClose")
         BluetoothGetRadioInfo              = GetFunction(Lib, "BluetoothGetRadioInfo")
         BluetoothGetDeviceInfo             = GetFunction(Lib, "BluetoothGetDeviceInfo")
         BluetoothDisplayDeviceProperties   = GetFunction(Lib, "BluetoothDisplayDeviceProperties")
         BluetoothEnableDiscovery           = GetFunction(Lib, "BluetoothEnableDiscovery")
         BluetoothEnableIncomingConnections = GetFunction(Lib, "BluetoothEnableIncomingConnections")
         BluetoothSelectDevices             = GetFunction(Lib, "BluetoothSelectDevices")
         BluetoothIsConnectable             = GetFunction(Lib, "BluetoothIsConnectable")
         BluetoothIsDiscoverable            = GetFunction(Lib, "BluetoothIsDiscoverable")
         BluetoothSelectDevicesFree         = GetFunction(Lib, "BluetoothSelectDevicesFree")
         BluetoothAuthenticateDevice        = GetFunction(Lib, "BluetoothAuthenticateDevice")
         BluetoothSetServiceState           = GetFunction(Lib, "BluetoothSetServiceState")
         BluetoothRemoveDevice              = GetFunction(Lib, "BluetoothRemoveDevice")
         BluetoothUpdateDeviceRecord        = GetFunction(Lib, "BluetoothUpdateDeviceRecord")
         
      EndIf
      
      ProcedureReturn Lib
   EndProcedure
   
   Procedure DeInitDLL()
      If Lib
         CloseLibrary(Lib)
         Lib = 0
      EndIf
   EndProcedure

   ;Bthprops.lib is available in the Windows Vista SDK, see:
   ;http://msdn.microsoft.com/en-us/library/aa363058%28VS.85%29.aspx
   
   ;oder:
   ;C:\Windows\SysWOW64\bthprops.cpl  (x86)
   ;bzw.
   ;C:\Windows\System32\bthprops.cpl  (x64)
   
;    Import "bthprops.lib"
;       BluetoothFindFirstDevice.l(*pbtsp, *pbtdi)
;       BluetoothFindNextDevice.l(hFind, *pbtdi)
;       BluetoothFindDeviceClose.l(hFind)
;       BluetoothFindFirstRadio.l(*pbtfrp, *phRadio)
;       BluetoothFindNextRadio.l(hFind, *phRadio)
;       BluetoothFindRadioClose.l(hFind)
;       BluetoothGetRadioInfo.l(hRadio, *pRadioInfo)
;       BluetoothGetDeviceInfo.l(hRadio, *pbtdi)
;       BluetoothDisplayDeviceProperties.l(hwndParent, *pbtdi)
;       BluetoothEnableDiscovery(hRadio, fEnabled)
;       BluetoothEnableIncomingConnections(hRadio, fEnabled)
;       BluetoothSelectDevices(*pbtsdp)
;       BluetoothIsConnectable(hRadio)
;       BluetoothIsDiscoverable(hRadio)
;       BluetoothSelectDevicesFree(*pbtsdp)
;       BluetoothAuthenticateDevice(hwndParent, hRadio, *pbtdi, *pszPasskey, ulPasskeyLength)
;       BluetoothSetServiceState(hRadio, *pbtdi, *pGuidService, dwServiceFlags.l)
;       BluetoothRemoveDevice(*pAddress.BLUETOOTH_ADDRESS)
;       BluetoothUpdateDeviceRecord(*pbtdi)
;
;    EndImport

   Procedure GetLastError()
      ProcedureReturn LastError
   EndProcedure

   Procedure GetDeviceTimeLastSeen(Num)
      ;/-------------
      ;| returns the time, the device was last seen
      ;|
      ;| other possible values:
      ;| #ERROR_NOT_FOUND         : this device is not available (at the moment)
      ;|                            or not connected
      ;| #ERROR_INVALID_PARAMETER : Num is out of range
      ;/-------------
      Protected *ST.SYSTEMTIME, Result = #ERROR_INVALID_PARAMETER

      If Num >= 0 And Num < NumDevices
         *ST    = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\stLastSeen)
         Result = Date(*ST\wYear, *ST\wMonth, *ST\wDay, *ST\wHour, *ST\wMinute, *ST\wSecond)
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure GetDeviceTimeLastUsed(Num)
      ;/-------------
      ;| returns the time, the device was last used
      ;|
      ;| other possible values:
      ;| #ERROR_NOT_FOUND         : this device is not available (at the moment)
      ;|                            or not connected
      ;| #ERROR_INVALID_PARAMETER : Num is out of range
      ;/-------------
      Protected *ST.SYSTEMTIME, Result = #ERROR_INVALID_PARAMETER

      If Num >= 0 And Num < NumDevices
         *ST    = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\stLastUsed)
         Result = Date(*ST\wYear, *ST\wMonth, *ST\wDay, *ST\wHour, *ST\wMinute, *ST\wSecond)
      EndIf

      ProcedureReturn Result
   EndProcedure

; Procedure DisconnectDevice(Num)
;    Protected *pbtdi.BLUETOOTH_DEVICE_INFO
;    
;    If Num >= 0 And Num < NumDevices
;       *pbtdi = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO)
;       *pbtdi\fAuthenticated = #False
;       *pbtdi\fConnected     = #False
;       ;*pbtdi\fRemembered    = #False
;       BluetoothUpdateDeviceRecord(*pbtdi)
;    EndIf
; EndProcedure

   Procedure RefreshDeviceInfo(Num)
      ;/-------------
      ;| returns #ERROR_SUCCESS on Success
      ;|
      ;| other possible values:
      ;| #ERROR_NOT_FOUND         : this device is not available (at the moment)
      ;|                            or not connected
      ;| #ERROR_INVALID_PARAMETER : Num is out of range
      ;/-------------
      Protected Result = #ERROR_INVALID_PARAMETER

      If Num >= 0 And Num < NumDevices
         ;BluetoothUpdateDeviceRecord(*THIS\Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO))
         Result = BluetoothGetDeviceInfo(Handle, *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO))
      EndIf
      If Result <> #ERROR_SUCCESS
         LastError = Result
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure RemoveDevice(Num)
      ;/-------------
      ;| returns #ERROR_SUCCESS on Success
      ;|
      ;| other possible values:
      ;| #ERROR_NOT_FOUND         : this device is not available (at the moment)
      ;|                            or not connected
      ;| #ERROR_INVALID_PARAMETER : Num is out of range
      ;/-------------
      Protected Result = #ERROR_INVALID_PARAMETER, *pAddress

      If Num >= 0 And Num < NumDevices
         *pAddress = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\Address) + 4
         Result    = BluetoothRemoveDevice(*pAddress)
         RefreshDeviceInfo(Num)
      EndIf
      If Result <> #ERROR_SUCCESS
         LastError = Result
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure AddSerialPortToDevice(Num, Mode)
      ;/-------------
      ;| returns #ERROR_SUCCESS on Success
      ;|
      ;| other possible values:
      ;| #ERROR_INVALID_PARAMETER      : Num is out of range
      ;| #ERROR_SERVICE_DOES_NOT_EXIST : No Bluetooth to serial service available
      ;| #E_INVALIDARG                 : You tried to de/activate, but it is allready de/activated
      ;/-------------
      Protected Result = #ERROR_INVALID_PARAMETER

      If Num >= 0 And Num < NumDevices
         If Mode
            Mode = #True
         EndIf
         Result = BluetoothSetServiceState(Handle, *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO), ?GUID_SerialPortServiceClass_UUID, Mode)
      EndIf
      If Result = #ERROR_SUCCESS
         RefreshDeviceInfo(Num)
      Else
         LastError = Result
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure AuthenticateDevice(Num, Password.s = "")
      ;/-------------
      ;| returns #ERROR_SUCCESS on Success
      ;|
      ;| other possible values:
      ;| #ERROR_INVALID_PARAMETER      : Num is out of range
      ;| #ERROR_NO_MORE_ITEMS          : The device is already marked as authenticated
      ;| #WAIT_TIMEOUT                 : The device didn't respond in time
      ;| #ERROR_DEVICE_NOT_CONNECTED
      ;| #ERROR_GEN_FAILURE
      ;| #ERROR_NOT_AUTHENTICATED
      ;| #ERROR_NOT_ENOUGH_MEMORY
      ;| #ERROR_REQ_NOT_ACCEP
      ;| #ERROR_ACCESS_DENIED
      ;| #ERROR_NOT_READY
      ;| #ERROR_VC_DISCONNECTED
      ;/-------------
      Protected Result = #ERROR_INVALID_PARAMETER, *Buffer, L

      If Num >= 0 And Num < NumDevices
         If Password
            L       = Len(Password)
            *Buffer = AllocateMemory(StringByteLength(Password, #PB_Unicode) + 2)
            PokeS(*Buffer, Password, -1, #PB_Unicode)
         EndIf
         Result = BluetoothAuthenticateDevice(#Null, Handle, *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO), *Buffer, L)

         If L
            FreeMemory(*Buffer)
         EndIf
      EndIf
      If Result = #ERROR_SUCCESS
         RefreshDeviceInfo(Num)
      Else
         LastError = Result
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure IsDeviceAuthenticated(Num)
      ;/-------------
      ;| returns <> 0 if device is authenticated
      ;|
      ;| other possible values:
      ;| #False : This device is not authenticated
      ;/-------------
      Protected Result

      If Num >= 0 And Num < NumDevices
         Result = PeekL(*Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\fAuthenticated))
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure IsDeviceConnected(Num)
      ;/-------------
      ;| returns <> 0 if device is connected
      ;|
      ;| other possible values:
      ;| #False : This device is not connected
      ;/-------------
      Protected Result

      If Num >= 0 And Num < NumDevices
         Result = PeekL(*Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\fConnected))
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure GetDeviceInfo(Num, *pbtdi.BLUETOOTH_DEVICE_INFO)
      Protected Result = #ERROR_INVALID_PARAMETER

      If Num >= 0 And Num < NumDevices
         If *pbtdi
            If CopyMemory(*Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO), *pbtdi, SizeOf(BLUETOOTH_DEVICE_INFO))
               Result = #True
            EndIf
         Else
            Result = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO)
         EndIf
      EndIf
      If Result = #ERROR_INVALID_PARAMETER
         LastError = Result
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure.s GetDeviceAddress(Num)
      Protected i, Result.s, *pAddress.BLUETOOTH_ADDRESS

      If Num >= 0 And Num < NumDevices
         *pAddress = *Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\Address)
         For i = 5 To 1 Step - 1
            Result + RSet(Hex(*pAddress\rgBytes[i], #PB_Byte), 2, "0") + ":"
         Next i
         Result + RSet(Hex(*pAddress\rgBytes[0], #PB_Byte), 2, "0")
      Else
         LastError = #ERROR_INVALID_PARAMETER
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure.s GetDeviceName(Num)
      Protected Result.s

      If Num >= 0 And Num < NumDevices
         Result = PeekS(*Devices + Num * SizeOf(BLUETOOTH_DEVICE_INFO) + OffsetOf(BLUETOOTH_DEVICE_INFO\szName), -1, #PB_Unicode)
      Else
         LastError = #ERROR_INVALID_PARAMETER
      EndIf

      ProcedureReturn Result
   EndProcedure

   Procedure CountFoundDevices()
      ;/-----------
      ;| returns the number of
      ;| found devices
      ;/-----------
      ProcedureReturn NumDevices
   EndProcedure

   Procedure DisconnectLocal()
      ;/-----------
      ;| Call this at the end of your
      ;| program, or if you are finished
      ;| with bluetooth.
      ;/-----------
      If Handle
         CloseHandle_(Handle)
         Handle     = #Null
         NumDevices = 0
      EndIf
   EndProcedure

   Procedure ConnectLocal()
      ;/-------------
      ;| Tries to connect to your local Bluetooth
      ;| Call this before you try to Scan.
      ;|
      ;| On Success it will return something other then #False
      ;/-------------
      Protected pbtfrp.BLUETOOTH_FIND_RADIO_PARAMS, hFind
      
      DisconnectLocal()
      pbtfrp\dwSize = SizeOf(BLUETOOTH_FIND_RADIO_PARAMS)
      hFind         = BluetoothFindFirstRadio(@pbtfrp, @Handle)
      Debug hFind
      If hFind
         If BluetoothIsConnectable(Handle) = #False
            BluetoothEnableIncomingConnections(Handle, #True)
         EndIf
         If BluetoothIsDiscoverable(Handle) = #False
            BluetoothEnableDiscovery(Handle, #True)
         EndIf
         BluetoothFindRadioClose(hFind)
      Else
         LastError = #ERROR_SERVICE_NOT_ACTIVE
      EndIf

      ProcedureReturn hFind
   EndProcedure

   Procedure ScanDevices(SearchTime, IgnoreUnnamedDevices = #False)
      ;/----------------
      ;| Scan for radio devices
      ;|
      ;| REMARK:
      ;| This procedure will NOT return before SearchTime (in Seconds).
      ;| So be prepared, that your application will halt for this time.
      ;| Better call it through a thread.
      ;|
      ;| Returns the number of found deviced
      ;/----------------
      Protected *pbtsp.BLUETOOTH_DEVICE_SEARCH_PARAMS, f.f  ;36
      Protected *pbtdi.BLUETOOTH_DEVICE_INFO                ;560
      Protected hFind, *Buffer, x, y

      NumDevices = 0
      If Handle = 0
         ConnectLocal()
      EndIf
      
      If Handle
         *pbtsp = AllocateMemory(SizeOf(BLUETOOTH_DEVICE_SEARCH_PARAMS))
         *pbtdi = AllocateMemory(SizeOf(BLUETOOTH_DEVICE_INFO))

         f = SearchTime / 1.28
         If f > 48
            SearchTime = 48
         ElseIf f < 0
            SearchTime = 0
         Else
            SearchTime = Int(f)
         EndIf
         *pbtsp\dwSize               = SizeOf(BLUETOOTH_DEVICE_SEARCH_PARAMS)
         *pbtsp\fReturnUnknown       = #True
         *pbtsp\fReturnAuthenticated = #True
         *pbtsp\fReturnConnected     = #True
         *pbtsp\fReturnRemembered    = #True
         *pbtsp\fIssueInquiry        = #True
         *pbtsp\hRadio               = Handle
         *pbtsp\cTimeoutMultiplier   = SearchTime
         *pbtdi\dwSize               = SizeOf(BLUETOOTH_DEVICE_INFO)

         
         hFind = BluetoothFindFirstDevice(*pbtsp, *pbtdi)

         If hFind
            Repeat
               If PeekW(*pbtdi + OffsetOf(BLUETOOTH_DEVICE_INFO\szName)) Or IgnoreUnnamedDevices = #False
                  CopyMemory(*pbtdi, *Devices + NumDevices * SizeOf(BLUETOOTH_DEVICE_INFO), SizeOf(BLUETOOTH_DEVICE_INFO))
                  NumDevices + 1
                  If NumDevices >= MaxDevices
                     MaxDevices + 10
                     *Devices = ReAllocateMemory(*Devices, MaxDevices * SizeOf(BLUETOOTH_DEVICE_INFO))
                  EndIf
               EndIf
            Until BluetoothFindNextDevice(hFind, *pbtdi) = 0
            BluetoothFindDeviceClose(hFind)
         Else
            ;Debug GetLastError_()
            LastError = #ERROR_NO_MORE_ITEMS
         EndIf

         FreeMemory(*pbtsp)
         FreeMemory(*pbtdi)
      EndIf

      ProcedureReturn NumDevices
   EndProcedure
   
   Procedure DeInitBlueTooth()
      
      
      DisconnectLocal()
      If *Devices
         FreeMemory(*Devices)
         *Devices = #Null
      EndIf
      DeInitDLL()
      
   EndProcedure
      

   Procedure InitBlueTooth()
      ;/----------
      ;| Call this first
      ;/----------

      If OSVersion() < #PB_OS_Windows_XP
         ProcedureReturn #False
      EndIf
      If Lib = 0
         InitDll()
      EndIf


      MaxDevices = 10
      NumDevices = 0
      Handle     = 0
      *Devices   = AllocateMemory(MaxDevices * SizeOf(BLUETOOTH_DEVICE_INFO))

      ProcedureReturn *Devices
   EndProcedure

   DataSection
      GUID_SerialPortServiceClass_UUID:
      Data.l $00001101
      Data.w $0000, $1000
      Data.b $80, $00, $00, $80, $5F, $9B, $34, $FB
   EndDataSection
   
EndModule


CompilerIf #PB_Compiler_IsMainFile
   ;Example
   
   Enumeration
      #Window_BlueTooth
   EndEnumeration
   
   Enumeration
      #BT_ClientList
      #BT_ScanButton
      #BT_Text_Log
      #BT_Log
   EndEnumeration
   
   Enumeration
      #Popup_Menu_Bluetooth
   EndEnumeration
   
   Enumeration
      #MenuItem_BT_Authenticate
      #MenuItem_BT_AddSerialPort
      #MenuItem_BT_RemoveDevice
   EndEnumeration
   
   Enumeration
      #StatusBar_BlueTooth
   EndEnumeration
   
   Enumeration
      #Timer_BlueTooth
   EndEnumeration
   
   ;Helper for our Connect-Thread
   Structure _BLUETOOTH_HELPER_
      Num.i
      SerialPortAdded.i
      i.i
      Password.s
   EndStructure
   
   Procedure.s GetErrorMessage(Error = #PB_Default)
      ;Get WinAPI-Error-Message
      
      Protected Result.s = "No Error", Msg.s
      
      If Error = #PB_Default
         Error = GetLastError_()
      EndIf
      
      Msg = Space(1024)
      If FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM, 0, Error, 0, @Msg, 1024, 0)
         Result = Msg
      EndIf
      
      ProcedureReturn Result
   EndProcedure
   
   Procedure BT_Log(Text.s)
      AddGadgetItem(#BT_Log, -1, FormatDate("[%hh:%ii:%ss] ", Date()) + Text)
      SendMessage_(GadgetID(#BT_Log), #EM_SCROLLCARET, #SB_BOTTOM, 0)
   EndProcedure
   
   Procedure BT_Window_CallBack(hWnd, MSG, wparam, lparam)
      ;Use a callback, because PB still looses Events, when User moves the window.
      ;This is inacceptable, when you wait for a message.
      ;(Well in fact this behaviour is ALLWAYS inacceptable, but i guess it will never change...)
      
      Protected i, j, Result = #PB_ProcessPureBasicEvents
      
      Select MSG
         Case #WM_APP
            DisableGadget(#BT_ScanButton, 0)
            j = BLUETOOTH::CountFoundDevices()
            BT_Log(Str(j) + " devices found!")
            For i = 1 To j
               AddGadgetItem(#BT_ClientList, -1, BLUETOOTH::GetDeviceName(i - 1) + " (" + BLUETOOTH::GetDeviceAddress(i - 1) + ")")
            Next i
      EndSelect
      
      ProcedureReturn Result
   EndProcedure
   
   Procedure BT_ScanThread(TimeOUT)
      ;We are scanning within a thread,
      ;so our program won't freeze the whole time.
      
      If BLUETOOTH::ScanDevices(TimeOUT) = #ERROR_SUCCESS
         SendMessage_(WindowID(#Window_BlueTooth), #WM_APP, 1, 1)
      Else
         SendMessage_(WindowID(#Window_BlueTooth), #WM_APP, 0, 0)
      EndIf
      
   EndProcedure
   
   Procedure BT_ConnectThread(*BT_Client._BLUETOOTH_HELPER_)
      ;Another Thread
      ;This one tries to connect, authenticate and
      ;opens a virtual serial port.
      Protected i, j
      
      i = *BT_Client\i
      If BLUETOOTH::IsDeviceAuthenticated(i)
         BT_Log("Device is allready authenticated.")
         *BT_Client\Num = i
         j              = #True
      Else
         BT_Log("Trying to authenticate " + BLUETOOTH::GetDeviceName(i) + "...")
         Delay(2000)
         If BLUETOOTH::AuthenticateDevice(i, *BT_Client\Password) = #ERROR_SUCCESS
            BT_Log("Successfully authenticated!")
            *BT_Client\Num = i
            j              = #True
         Else
            Delay(2000)
            If BLUETOOTH::AuthenticateDevice(i, *BT_Client\Password) = #ERROR_SUCCESS
               BT_Log("Successfully authenticated!")
               *BT_Client\Num = i
               j              = #True
            Else
               BT_Log("Authentication Error!(" + GetErrorMessage(BLUETOOTH::GetLastError()) + ")")
               j = #False
            EndIf
         EndIf
      EndIf
      
      If j
         ;Authenticated, now wait a little bit, before adding serial port
         Delay(2500)
         If BLUETOOTH::AddSerialPortToDevice(i, #True) = #ERROR_SUCCESS
            BT_Log("Serial Port successful connected!")
            *BT_Client\Num             = i
            *BT_Client\SerialPortAdded = #True
         ElseIf BLUETOOTH::GetLastError() = #E_INVALIDARG
            BT_Log("Serial Port allready there...")
            *BT_Client\Num             = i
            *BT_Client\SerialPortAdded = #True
         Else
            BT_Log("Error while trying to connect serial port.")
            *BT_Client\Num             = i
            *BT_Client\SerialPortAdded = 0
         EndIf
      EndIf
      
      DisableGadget(#BT_ScanButton, 0)
      
   EndProcedure
   
   Procedure BT_CheckActiveClient(*BT_Client._BLUETOOTH_HELPER_, Num)
      
      If *BT_Client\Num > -1 And Num <> *BT_Client\Num
         If *BT_Client\SerialPortAdded
            BLUETOOTH::AddSerialPortToDevice(*BT_Client\Num, #False)
         EndIf
         BLUETOOTH::RemoveDevice(*BT_Client\Num)
         *BT_Client\Num             = -1
         *BT_Client\SerialPortAdded = 0
      EndIf
      
   EndProcedure
   
   Procedure OpenWindow_Bluetooth()
      
      OpenWindow(#Window_BlueTooth, 0, 0, 300, 400, "", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
      SetWindowCallback(@BT_Window_CallBack(), #Window_BlueTooth)
      AddWindowTimer(#Window_BlueTooth, #Timer_BlueTooth, 900)
      ListIconGadget(#BT_ClientList, 5, 5, 290, 250, "Clients", 290)
      TextGadget(#BT_Text_Log, 5, 268, 50, 20, "Log:")
      ButtonGadget(#BT_ScanButton, 110, 260, 80, 22, "ReScan")
      EditorGadget(#BT_Log, 5, 288, 290, 88, #PB_Editor_ReadOnly)
      CreateStatusBar(#StatusBar_BlueTooth, WindowID(#Window_BlueTooth))
      AddStatusBarField(#PB_Ignore)
      
      If CreatePopupMenu(#Popup_Menu_Bluetooth)
         MenuItem(#MenuItem_BT_Authenticate, "Authenticate")
         MenuItem(#MenuItem_BT_AddSerialPort, "Add Serial Port")
         MenuBar()
         MenuItem(#MenuItem_BT_RemoveDevice, "Remove Device")
      EndIf
      
   EndProcedure
   
   Procedure main()
      Protected i, j, a$, BT_Scan_Duration, BT_ThreadID_A, BT_ThreadID_B, BT_Client._BLUETOOTH_HELPER_

      
      If BLUETOOTH::InitBlueTooth() = 0
         MessageRequester("Error!", "You need at least Windows XP!")
         ProcedureReturn
      EndIf
      
      OpenWindow_Bluetooth()
      BT_Client\Num = -1
      BT_ThreadID_A = CreateThread(@BT_ScanThread(), 12)
      If BT_ThreadID_A
         BT_Scan_Duration = ElapsedMilliseconds() + 12 * 1000
         DisableGadget(#BT_ScanButton, 1)
         BT_Log("Scanning started, please wait...")
      EndIf
      
      Repeat
         Select WaitWindowEvent()
            Case #PB_Event_CloseWindow
               If EventWindow() = #Window_BlueTooth
                  Break
               EndIf
            Case #PB_Event_Timer
               Select EventTimer()
                  Case #Timer_BlueTooth
                     If BT_ThreadID_A And IsThread(BT_ThreadID_A)
                        StatusBarText(#StatusBar_BlueTooth, 0, "Scanning another " + Str(Int((BT_Scan_Duration - ElapsedMilliseconds()) / 1000)) + "s")
                     ElseIf BT_ThreadID_A
                        BT_ThreadID_A = 0
                        StatusBarText(#StatusBar_BlueTooth, 0, "")
                     EndIf
               EndSelect
            Case #PB_Event_Menu
               Select EventMenu()
                  Case #MenuItem_BT_AddSerialPort
                     i = GetGadgetState(#BT_ClientList)
                     If i > -1
                        BT_CheckActiveClient(@BT_Client, i)
                        If BT_Client\SerialPortAdded
                           If BLUETOOTH::AddSerialPortToDevice(i, #False) = #ERROR_SUCCESS
                              BT_Client\Num             = i
                              BT_Client\SerialPortAdded = #False
                              BT_Log("Serial Port successfully disconnected!")
                           ElseIf BLUETOOTH::GetLastError() = #E_INVALIDARG
                              BT_Client\Num             = i
                              BT_Client\SerialPortAdded = #False
                              BT_Log("Serial Port is allready disconnected...")
                           Else
                              BT_Log("Something went wrong...")
                           EndIf
                        Else
                           If BLUETOOTH::AddSerialPortToDevice(i, #True) = #ERROR_SUCCESS
                              BT_Log("Serial Port successfully connected!")
                              BT_Client\Num             = i
                              BT_Client\SerialPortAdded = #True
                           ElseIf BLUETOOTH::GetLastError() = #E_INVALIDARG
                              BT_Log("Serial Port is allready connected...")
                              BT_Client\Num             = i
                              BT_Client\SerialPortAdded = #True
                           ElseIf BLUETOOTH::GetLastError() = #ERROR_SERVICE_DOES_NOT_EXIST
                              BT_Log("This Service is not supported!")
                           Else
                              BT_Log("Something went wrong... (" + Str(BLUETOOTH::GetLastError()) + ")")
                           EndIf
                        EndIf
                     EndIf
                  Case #MenuItem_BT_Authenticate
                     i = GetGadgetState(#BT_ClientList)
                     If i > -1
                        BT_CheckActiveClient(@BT_Client, i)
                        If GetMenuItemState(#Popup_Menu_Bluetooth, #MenuItem_BT_Authenticate)
                           BT_Log("You are allready authenticated!")
                           BT_Client\Num = i
                        Else
                           a$ = InputRequester("Enter Password", "Enter Password for authentication", "")
                           If a$ And BLUETOOTH::AuthenticateDevice(i, a$) = #ERROR_SUCCESS
                              BT_Log("Successfully authenticated!")
                              BT_Client\Num = i
                           Else
                              BT_Log("Authentication Error!(" + GetErrorMessage(BLUETOOTH::GetLastError()) + ")")
                           EndIf
                        EndIf
                     EndIf
                  Case #MenuItem_BT_RemoveDevice
                     i = GetGadgetState(#BT_ClientList)
                     If i > -1
                        If BT_Client\i = i
                           BT_CheckActiveClient(@BT_Client, i)
                        Else
                           BLUETOOTH::RemoveDevice(i)
                        EndIf
                        RemoveGadgetItem(#BT_ClientList, i)
                     EndIf
               EndSelect
            Case #PB_Event_Gadget
               Select EventGadget()
                  Case #BT_ScanButton
                     ClearGadgetItems(#BT_ClientList)
                     BT_CheckActiveClient(@BT_Client, -1)
                     StatusBarText(#StatusBar_BlueTooth, 0, "")
                     BT_Scan_Duration = ElapsedMilliseconds() + 12 * 1000
                     BT_ThreadID_A    = CreateThread(@BT_ScanThread(), 12)
                     If BT_ThreadID_A
                        DisableGadget(#BT_ScanButton, 1)
                        BT_Log("Scanning started...")
                     EndIf
                  Case #BT_ClientList
                     i = GetGadgetState(#BT_ClientList)
                     If BT_ThreadID_B = 0 Or IsThread(BT_ThreadID_B) = 0
                        Select EventType()
                           Case #PB_EventType_LeftDoubleClick
                              If i > -1
                                 BT_Client\Password = InputRequester("Enter Password", "Enter Password for authentication", BT_Client\Password)
                                 BT_CheckActiveClient(@BT_Client, i)
                                 BT_Client\i   = i
                                 BT_ThreadID_B = CreateThread(@BT_ConnectThread(), @BT_Client)
                                 If BT_ThreadID_B
                                    DisableGadget(#BT_ScanButton, 1)
                                 EndIf
                              EndIf
                           Case #PB_EventType_RightClick
                              If i > -1
                                 If BLUETOOTH::IsDeviceAuthenticated(i)
                                    SetMenuItemState(#Popup_Menu_Bluetooth, #MenuItem_BT_Authenticate, 1)
                                 Else
                                    SetMenuItemState(#Popup_Menu_Bluetooth, #MenuItem_BT_Authenticate, 0)
                                 EndIf
                                 DisplayPopupMenu(#Popup_Menu_Bluetooth, WindowID(#Window_BlueTooth))
                              EndIf
                        EndSelect
                     EndIf
               EndSelect
               
         EndSelect
      ForEver
      
      If BT_ThreadID_B And IsThread(BT_ThreadID_B)
         If WaitThread(BT_ThreadID_B, 2000) = 0
            KillThread(BT_ThreadID_B)
         EndIf
      EndIf
      
      If BT_ThreadID_A And IsThread(BT_ThreadID_A)
         If WaitThread(BT_ThreadID_A, 2000) = 0
            KillThread(BT_ThreadID_A)
         EndIf
      EndIf
      
      
      BT_CheckActiveClient(@BT_Client, -1)
      BLUETOOTH::DisconnectLocal()
   EndProcedure
   
   main()   
   
   
CompilerEndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 955
; FirstLine = 917
; Folding = ------
; EnableXP