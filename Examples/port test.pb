XIncludeFile "BlueTooth.pbi"

;EnableExplicit
;Global *BTI._BLUETOOTH_

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
         j = *BTI\CountFoundDevices()
         BT_Log(Str(j) + " devices found!")
         For i = 1 To j
            AddGadgetItem(#BT_ClientList, -1, *BTI\GetDeviceName(i - 1) + " (" + *BTI\GetDeviceAddress(i - 1) + ")")
         Next i
   EndSelect

   ProcedureReturn Result
EndProcedure

Procedure BT_ScanThread(TimeOUT)
   ;We are scanning within a thread,
   ;so our program won't freeze the whole time.

   If *BTI\ScanDevices(TimeOUT) = #ERROR_SUCCESS
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
   If *BTI\IsDeviceAuthenticated(i)
      BT_Log("Device is allready authenticated.")
      *BT_Client\Num = i
      j              = #True
   Else
      BT_Log("Trying to authenticate " + *BTI\GetDeviceName(i) + "...")
      Delay(2000)
      If *BTI\AuthenticateDevice(i, *BT_Client\Password) = #ERROR_SUCCESS
         BT_Log("Successfully authenticated!")
         *BT_Client\Num = i
         j              = #True
      Else
         Delay(2000)
         If *BTI\AuthenticateDevice(i, *BT_Client\Password) = #ERROR_SUCCESS
            BT_Log("Successfully authenticated!")
            *BT_Client\Num = i
            j              = #True
         Else
            BT_Log("Authentication Error!(" + GetErrorMessage(*BTI\GetLastError()) + ")")
            j = #False
         EndIf
      EndIf
   EndIf

   If j
      ;Authenticated, now wait a little bit, before adding serial port
      Delay(2500)
      If *BTI\AddSerialPortToDevice(i, #True) = #ERROR_SUCCESS
         BT_Log("Serial Port successful connected!")
         *BT_Client\Num             = i
         *BT_Client\SerialPortAdded = #True
      ElseIf *BTI\GetLastError() = #E_INVALIDARG
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
         *BTI\AddSerialPortToDevice(*BT_Client\Num, #False)
      EndIf
      *BTI\RemoveDevice(*BT_Client\Num)
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

   *BTI = CreateBlueToothInterface()

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
                        If *BTI\AddSerialPortToDevice(i, #False) = #ERROR_SUCCESS
                           BT_Client\Num             = i
                           BT_Client\SerialPortAdded = #False
                           BT_Log("Serial Port successfully disconnected!")
                        ElseIf *BTI\GetLastError() = #E_INVALIDARG
                           BT_Client\Num             = i
                           BT_Client\SerialPortAdded = #False
                           BT_Log("Serial Port is allready disconnected...")
                        Else
                           BT_Log("Something went wrong...")
                        EndIf
                     Else
                        If *BTI\AddSerialPortToDevice(i, #True) = #ERROR_SUCCESS
                           BT_Log("Serial Port successfully connected!")
                           BT_Client\Num             = i
                           BT_Client\SerialPortAdded = #True
                        ElseIf *BTI\GetLastError() = #E_INVALIDARG
                           BT_Log("Serial Port is allready connected...")
                           BT_Client\Num             = i
                           BT_Client\SerialPortAdded = #True
                        Else
                           BT_Log("Something went wrong...")
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
                        If a$ And *BTI\AuthenticateDevice(i, a$) = #ERROR_SUCCESS
                           BT_Log("Successfully authenticated!")
                           BT_Client\Num = i
                        Else
                           BT_Log("Authentication Error!(" + GetErrorMessage(*BTI\GetLastError()) + ")")
                        EndIf
                     EndIf
                  EndIf
               Case #MenuItem_BT_RemoveDevice
                  i = GetGadgetState(#BT_ClientList)
                  If i > -1
                     If BT_Client\i = i
                        BT_CheckActiveClient(@BT_Client, i)
                     Else
                        *BTI\RemoveDevice(i)
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
                              If *BTI\IsDeviceAuthenticated(i)
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
   *BTI\DisconnectLocal()
EndProcedure

main()
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 2
; Folding = --
; EnableXP