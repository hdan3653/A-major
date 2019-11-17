CompilerIf #PB_Compiler_Version >= 530
  IncludeFile "includes/cv_functions.pbi"

  Global lpPrevWndFunc

  #CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
  #CV_DESCRIPTION = "Using OpenGL and textures, the webcam interface is displayed onto the surfaces of a rotating cube."

  ProcedureC ConvertIplToTexture(*image.IplImage)
    glGenTextures_(1, @texturePTR)
    glBindTexture_(#GL_TEXTURE_2D, texturePTR)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_REPEAT)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_REPEAT)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST)
    gluBuild2DMipmaps_(#GL_TEXTURE_2D, #GL_RGB, *image\width, *image\height, #GL_BGR_EXT, #GL_UNSIGNED_BYTE, *image\imageData)
    ProcedureReturn texturePTR
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

  Repeat
    nCreate + 1
    *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
  Until nCreate = 5 Or *capture

  If *capture
    FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
    FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
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

      If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
        MenuItem(10, "Exit")
      EndIf
      ToolTip(window_handle, #CV_DESCRIPTION)

      If OSVersion() > #PB_OS_Windows_XP : SetParent_(window_handle, WindowID(0)) : EndIf

      BringToTop(WindowID(0))
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
      gluPerspective_(25, FrameWidth / FrameHeight, 1, 60)
      glMatrixMode_(#GL_MODELVIEW)
      glClearColor_(0, 0, 0, 1)
      glClearDepth_(1)
      glEnable_(#GL_DEPTH_TEST)
      glDepthFunc_(#GL_LEQUAL)
      glHint_(#GL_PERSPECTIVE_CORRECTION_HINT, #GL_NICEST)
      glShadeModel_(#GL_SMOOTH)
      glDisable_(#GL_DITHER)
      glEnable_(#GL_CULL_FACE)
      glCullFace_(#GL_BACK)
      glEnable_(#GL_TEXTURE_2D)
      *image.IplImage

      Repeat
        *image = cvQueryFrame(*capture)

        If *image
          xRotation.f + 1.5
          yRotation.f - 2.5
          zRotation.f + 3.5
          texturePTR = ConvertIplToTexture(*image)
          glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
          glLoadIdentity_()
          glTranslatef_(0, 0, -7.5)
          glRotatef_(xRotation, 1, 0, 0)
          glRotatef_(yRotation, 0, 1, 0)
          glRotatef_(zRotation, 0, 0, 1)
          glBindTexture_(#GL_TEXTURE_2D, texturePTR)
          glBegin_(#GL_QUADS)
            glTexCoord2f_(1, 1) : glVertex3f_(1, 1, -1)
            glTexCoord2f_(0, 1) : glVertex3f_(-1, 1, -1)
            glTexCoord2f_(0, 0) : glVertex3f_(-1, 1, 1)
            glTexCoord2f_(1, 0) : glVertex3f_(1, 1, 1)
            glTexCoord2f_(1, 1) : glVertex3f_(-1, 1, 1)
            glTexCoord2f_(0, 1) : glVertex3f_(-1, 1, -1)
            glTexCoord2f_(0, 0) : glVertex3f_(-1, -1, -1)
            glTexCoord2f_(1, 0) : glVertex3f_(-1, -1, 1)
            glTexCoord2f_(1, 1) : glVertex3f_(1, 1, 1)
            glTexCoord2f_(0, 1) : glVertex3f_(-1, 1, 1)
            glTexCoord2f_(0, 0) : glVertex3f_(-1, -1, 1)
            glTexCoord2f_(1, 0) : glVertex3f_(1, -1, 1)
            glTexCoord2f_(1, 1) : glVertex3f_(-1, 1, -1)
            glTexCoord2f_(0, 1) : glVertex3f_(1, 1, -1)
            glTexCoord2f_(0, 0) : glVertex3f_(1, -1, -1)
            glTexCoord2f_(1, 0) : glVertex3f_(-1, -1, -1)
            glTexCoord2f_(1, 1) : glVertex3f_(1, 1, -1)
            glTexCoord2f_(0, 1) : glVertex3f_(1, 1, 1)
            glTexCoord2f_(0, 0) : glVertex3f_(1, -1, 1)
            glTexCoord2f_(1, 0) : glVertex3f_(1, -1, -1)
            glTexCoord2f_(1, 1) : glVertex3f_(1, -1, 1)
            glTexCoord2f_(0, 1) : glVertex3f_(-1, -1, 1)
            glTexCoord2f_(0, 0) : glVertex3f_(-1, -1, -1)
            glTexCoord2f_(1, 0) : glVertex3f_(1, -1, -1)
          glEnd_()
          cvWaitKey(1)
          SetGadgetAttribute(0, #PB_OpenGL_FlipBuffers, #True)
          glDeleteTextures_(1, @texturePTR)
        EndIf
      Until WindowEvent() = #PB_Event_CloseWindow Or exitCV
      FreeMemory(*param)
    EndIf
    cvDestroyAllWindows()
    cvReleaseCapture(@*capture)
  Else
    MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
  EndIf
CompilerElse
  MessageBox_(0, "This example can only run in PureBasic 5.30 or greater." + #CRLF$ + #CRLF$ + "Operation cancelled.", "PureBasic Interface to OpenCV", #MB_ICONERROR)
CompilerEndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
; 㼿㼿㼿㼿㼿㼿㼀㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿?㼿㼿㼿㼿㼿
; 㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿?㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿
; 㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿?㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿
; 㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿?㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿
; 㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿㼿?