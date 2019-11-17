CompilerIf #PB_Compiler_Version >= 530
  IncludeFile "includes/cv_functions.pbi"

  Global lpPrevWndFunc, Dim k.f(16), tempK.f, count, color

  #CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
  #CV_DESCRIPTION = "Using OpenGL to display various parametric curves." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Predefined settings." + Chr(10) + Chr(10) +
                  "- [ C ] KEY: Toggle color / layers." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to more information."

  Structure Point3D
    x.f
    y.f
    r.f 
    g.f
    b.f
  EndStructure

  Procedure GLHandler()
    RunProgram("https://en.wikipedia.org/w/index.php?title=Parametric_equation")
  EndProcedure

  ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
    Shared exitCV.b

    Select Msg
      Case #WM_COMMAND
        Select wParam
          Case 10
            HideWindow(0, 1)
            exitCV = #True
        EndSelect
      Case #WM_CHAR
        Select wParam
          Case #VK_SPACE
            If count = ArraySize(k()) - 1 : count = 0 : Else : count + 1 : tempK = 0 : EndIf
          Case #VK_C, 99
            color ! 1 : tempK = 0
          Case #VK_ESCAPE
            HideWindow(0, 1)
            exitCV = #True
        EndSelect
      Case #WM_DESTROY
        exitCV = #True
    EndSelect
    ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)
  EndProcedure

  ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
    Select event
      Case #CV_EVENT_RBUTTONDOWN
        DisplayPopupMenu(0, *param\uValue)
    EndSelect
  EndProcedure

  FrameWidth = 640
  FrameHeight = 480
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  cvMoveWindow(#CV_WINDOW_NAME, -1000, -1000)
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())
  hWnd = GetParent_(window_handle)
  ShowWindow_(hWnd, #SW_HIDE)

  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, #CV_WINDOW_NAME, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    SetWindowLongPtr_(WindowID(0), #GWL_WNDPROC, @WindowCallback())
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(WindowID(0), #WM_SETICON, 0, opencv)
    OpenGLGadget(0, 0, 0, FrameWidth, FrameHeight)
    BindGadgetEvent(0, @GLHandler(), #PB_EventType_LeftDoubleClick)

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(10, "Exit")
    EndIf
    ToolTip(window_handle, #CV_DESCRIPTION)

    If OSVersion() > #PB_OS_Windows_XP : SetParent_(window_handle, WindowID(0)) : EndIf

    BringToTop(WindowID(0))
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
    gluPerspective_(45, FrameWidth / FrameHeight, 1, 60)
    glMatrixMode_(#GL_MODELVIEW)
    glClearDepth_(1)
    glEnable_(#GL_DEPTH_TEST)
    glLoadIdentity_()
    glTranslatef_(0, 0, -15)
    Dim a.f(16)
    k(0) = 0.25 : k(1) = 0.33 : k(2) = 0.5 : k(3) = 0.65 : k(4) = 0.7 : k(5) = 1.3 : k(6) = 1.4 : k(7) = 1.6
    k(8) = 1.7 : k(9) = 1.8 : k(10) = 1.9 : k(11) = 2.5 : k(12) = 3 : k(13) = 4 : k(14) = 5 : k(15) = 6
    a(0) = 0.5 : a(1) = 0.7 : a(2) = 1.3 : a(3) = 1.8 : a(4) = 2

    For rtcount = 5 To 15
      a(rtcount) = 4
    Next

    Repeat
      If tempK <> k(count)
        n = 1 : t.f = 0
        Dim Point3D.Point3D(n)
        tempK = k(count) : b.f = a(count) / k(count)

        While t <= 50 * #PI
          Point3D(n - 1)\x = (a(count) - b) * Cos(t) + b * Cos(t * ((a(count) / b) - 1))
          Point3D(n - 1)\y = (a(count) - b) * Sin(t) - b * Sin(t * ((a(count) / b) - 1))

          If color
            Point3D(n - 1)\r = 0 : Point3D(n - 1)\g = 1 : Point3D(n - 1)\b = 0
          Else
            Point3D(n - 1)\r = Random(1) : Point3D(n - 1)\g = Random(1) : Point3D(n - 1)\b = Random(1)
          EndIf
          n + 1 : t + 0.01
          ReDim Point3D(n)
        Wend
      EndIf
      glViewport_(0, 0, FrameWidth, FrameHeight)
      glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
      glRotatef_(1, 0, 1, 0)
      glEnableClientState_(#GL_VERTEX_ARRAY)
      glEnableClientState_(#GL_COLOR_ARRAY)
      glVertexPointer_(3, #GL_FLOAT, SizeOf(Point3D), Point3D(0))
      glColorPointer_(3, #GL_FLOAT, SizeOf(Point3D), @Point3D(0)\r)
      glDrawArrays_(#GL_POINTS, 0, ArraySize(Point3D()))
      glDisableClientState_(#GL_COLOR_ARRAY)
      glDisableClientState_(#GL_VERTEX_ARRAY)
      cvWaitKey(1)
      SetGadgetAttribute(0, #PB_OpenGL_FlipBuffers, #True)
    Until WindowEvent() = #PB_Event_CloseWindow Or exitCV
    FreeMemory(*param)
  EndIf
  cvDestroyAllWindows()
CompilerElse
  MessageBox_(0, "This example can only run in PureBasic 5.30 or greater." + #CRLF$ + #CRLF$ + "Operation cancelled.", "PureBasic Interface to OpenCV", #MB_ICONERROR)
CompilerEndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 2
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\