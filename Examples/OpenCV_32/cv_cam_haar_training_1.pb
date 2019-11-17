IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Haar-Training in stages for single face recognition (new version)." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Start / Stop capture." + Chr(10) + Chr(10) +
                  "- [ H ] KEY: Toggle Haar-Cascade file." + Chr(10) + Chr(10) +
                  "- [ P ] KEY: Performance test XML file." + Chr(10) + Chr(10) +
                  "- [ S ] KEY: Create samples file." + Chr(10) + Chr(10) +
                  "- [ T ] KEY: Create training file." + Chr(10) + Chr(10) +
                  "- [ X ] KEY: Reset capture / count." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to more information."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared CaptureCV.b, exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 10
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
    Case #CV_EVENT_LBUTTONDBLCLK
      RunProgram("http://docs.opencv.org/doc/user_guide/ug_traincascade.html")
  EndSelect
EndProcedure

Procedure FileCount(FolderLocation.s, FileType.s)
  If ExamineDirectory(0, FolderLocation, FileType)
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File : rtnCount + 1 : EndIf
    Wend
    FinishDirectory(0)
  EndIf
  ProcedureReturn rtnCount
EndProcedure

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

  If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
    MenuItem(10, "Exit")
  EndIf
  hWnd = GetParent_(window_handle)
  opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
  SendMessage_(hWnd, #WM_SETICON, 0, opencv)
  wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
  SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
  cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
  ToolTip(window_handle, #CV_DESCRIPTION)
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  InitialPath.s = GetCurrentDirectory() + "trained\positives\"
  negCount = FileCount("trained\negatives\", "*.jpg")
  posCount = FileCount("trained\positives\", "*.jpg")
  whCapture = 80 : whOffset = 40 : nStages = 16 : whHaar = 20
  wFrame = FrameWidth - whOffset * 2 : hFrame = FrameHeight - whOffset * 2
  xFrame = (FrameWidth - wFrame) / 2 : yFrame = (FrameHeight - hFrame) / 2
  Dim haarcascade.s(2)
  haarcascade(0) = "haarcascade_frontalface_default.xml"
  haarcascade(1) = "haarcascade_frontalface_JHPJHP.xml"
  scale = 2
  iWidth = Round(FrameWidth / scale, #PB_Round_Nearest)
  iHeight = Round(FrameHeight / scale, #PB_Round_Nearest)
  *gray.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 1)
  *cascade.CvHaarClassifierCascade = cvLoad(haarcascade(0), #Null, #Null, #Null)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  *faces.CvSeq
  *element.CvRect
  *writer.CvVideoWriter : fps.d = 7
  *image.IplImage
  font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)

      If CaptureCV And face = 0
        If *writer
          cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)
          cvEqualizeHist(*gray, *gray)
          cvResize(*gray, *resize, #CV_INTER_AREA)
          cvClearMemStorage(*storage)
          *faces = cvHaarDetectObjects(*resize, *cascade, *storage, 1.1, 3, #CV_HAAR_DO_CANNY_PRUNING | #CV_HAAR_FIND_BIGGEST_OBJECT | #CV_HAAR_DO_ROUGH_SEARCH, 100, 100, 0, 0)

          For rtnPoint = 0 To *faces\total
            *element = cvGetSeqElem(*faces, rtnPoint)

            If *element
              If Abs(x - *element\x * scale) > 20 Or Abs(y - *element\y * scale) > 20
                x = *element\x * scale
                y = *element\y * scale
                width = (*element\x + *element\width) * scale
                height = (*element\y + *element\height) * scale

                If x <= xFrame Or width >= xFrame + wFrame Or y <= yFrame Or height >= yFrame + hFrame
                  x = 0 : y = 0 : width = 0 : height = 0
                EndIf
              EndIf
              Break
            Else
              x = 0 : y = 0 : width = 0 : height = 0
            EndIf
          Next

          If x > 0 And y > 0 And width > 0 And height > 0
            If Not IsFile(0) : OpenFile(0, "trained/pos_train.txt", #PB_File_Append) : EndIf
            If Not IsFile(0) : MessageBox_(0, "File locked: trained\pos_train.txt.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If width > height : iRatio.d = whCapture / width : Else : iRatio.d = whCapture / height : EndIf

            iWidth = width * iRatio
            iHeight = height * iRatio
            cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)

            If iWidth < iHeight
              *frame.IplImage = cvCreateImage(iWidth, iWidth, #IPL_DEPTH_8U, 1)
              cvSetImageROI(*gray, x - whOffset, y - whOffset, width - x + whOffset * 2, width - x + whOffset * 2)
            Else
              *frame.IplImage = cvCreateImage(iHeight, iHeight, #IPL_DEPTH_8U, 1)
              cvSetImageROI(*gray, x - whOffset, y - whOffset, height - y + whOffset * 2, height - y + whOffset * 2)
            EndIf
            cvResize(*gray, *frame, #CV_INTER_AREA)
            cvWriteFrame(*writer, *frame)
            cvResetImageROI(*gray)
            cvReleaseImage(@*frame)
            cvRectangle(*image, x, y, width, height, 255, 0, 0, 0, 2, #CV_AA, #Null)
            cvRectangleR(*image, xFrame, yFrame, wFrame, hFrame, 0, 255, 0, 0, 2, #CV_AA, #Null)
            WriteStringN(0, "positives/" + Str(posCount + 1) + ".jpg 1 0 0 " + Str(iWidth) + " " + Str(iHeight))
            posCount + 1
          Else
            cvRectangleR(*image, xFrame, yFrame, wFrame, hFrame, 0, 255, 255, 0, 2, #CV_AA, #Null)
          EndIf
        Else
          If posCount > 0
            sPath.s = "trained\positives\"
            sVideo.s = sPath + Str(posCount + 1) + ".jpg"
            *writer = cvCreateVideoWriter(sVideo, #CV_FOURCC_DEFAULT, fps, FrameWidth, FrameHeight, #True)
          Else
            If IsFile(0) : CloseFile(0) : EndIf

            DeleteFile("trained/positives.vec", #PB_FileSystem_Force)

            If FileSize("trained/positives.vec") > 0 : MessageBox_(0, "File locked: trained\positives.vec.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

            DeleteFile("trained/performance.txt", #PB_FileSystem_Force)
            DeleteFile("trained/pos_train.txt", #PB_FileSystem_Force)
            DeleteFile("haarcascade_frontalface_JHPJHP.xml", #PB_FileSystem_Force)
            DeleteDirectory("trained/tests", "*.*", #PB_FileSystem_Force)
            DeleteDirectory("trained/positives", "*.*", #PB_FileSystem_Force)
            DeleteDirectory("haarcascade_frontalface_JHPJHP", "*.*", #PB_FileSystem_Force | #PB_FileSystem_Recursive)

            If FileSize("trained/performance.txt") > 0 : MessageBox_(0, "File locked: trained\performance.txt.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("trained/pos_train.txt") > 0 : MessageBox_(0, "File locked: trained\pos_train.txt.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("haarcascade_frontalface_JHPJHP.xml") > 0 : MessageBox_(0, "File locked: haarcascade_frontalface_JHPJHP.xml.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("trained/tests") = -2 : MessageBox_(0, "Folder locked: trained\tests.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("trained/positives") = -2 : MessageBox_(0, "Folder locked: trained\positives.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("haarcascade_frontalface_JHPJHP") = -2 : MessageBox_(0, "Folder locked: haarcascade_frontalface_JHPJHP.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

            CreateDirectory("trained/positives")

            If FileSize("trained/positives") <> -2 : MessageBox_(0, "Cannot create folder: trained\positives.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

            sPath.s = PathRequester("Please select a location to save Positive frames:", InitialPath)

            If FileSize(sPath) = -2
              If OpenFile(0, "trained/pos_train.txt", #PB_File_Append)
                sVideo.s = sPath + Str(posCount + 1) + ".jpg"
                *writer = cvCreateVideoWriter(sVideo, #CV_FOURCC_DEFAULT, fps, FrameWidth, FrameHeight, #True)
              Else
                posCount = 0
                CaptureCV = #False
                MessageBox_(0, "Missing file: trained\pos_train.txt.", #CV_WINDOW_NAME, #MB_ICONERROR)
              EndIf
            Else
              posCount = 0
              CaptureCV = #False
            EndIf
          EndIf
          cvRectangleR(*image, xFrame, yFrame, wFrame, hFrame, 0, 0, 255, 0, 2, #CV_AA, #Null)

          If CaptureCV And Not *writer
            CaptureCV = #False
            MessageBox_(0, "Creating the video writer failed.", #CV_WINDOW_NAME, #MB_ICONERROR)
          EndIf
        EndIf
      Else
        If face
          cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)
          cvEqualizeHist(*gray, *gray)
          cvResize(*gray, *resize, #CV_INTER_AREA)
          cvClearMemStorage(*storage)
          *faces = cvHaarDetectObjects(*resize, *cascade, *storage, 1.1, 3, #CV_HAAR_DO_CANNY_PRUNING | #CV_HAAR_FIND_BIGGEST_OBJECT | #CV_HAAR_DO_ROUGH_SEARCH, 100, 100, 0, 0)

          For rtnPoint = 0 To *faces\total
            *element = cvGetSeqElem(*faces, rtnPoint)

            If *element
              If Abs(x - *element\x * scale) > 20 Or Abs(y - *element\y * scale) > 20
                x = *element\x * scale
                y = *element\y * scale
                width = (*element\x + *element\width) * scale
                height = (*element\y + *element\height) * scale
              EndIf
              cvRectangle(*image, x, y, width, height, 255, 255, 0, 0, 2, #CV_AA, #Null)
              Break
            EndIf
          Next
        Else
          cvRectangleR(*image, xFrame, yFrame, wFrame, hFrame, 0, 0, 255, 0, 2, #CV_AA, #Null)
        EndIf
      EndIf

      If face = 0
        total.s = Right("000" + Str(posCount), 4)
        cvPutText(*image, total, whOffset + 5, whOffset + 30, @font, 255, 255, 255, 0)
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(100)

      Select keyPressed
        Case 32
          CaptureCV ! 1

          If CaptureCV
            DeleteFile("trained/positives.vec", #PB_FileSystem_Force)

            If FileSize("trained/positives.vec") > 0 : MessageBox_(0, "File locked: trained\positives.vec.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

            DeleteFile("haarcascade_frontalface_JHPJHP.xml", #PB_FileSystem_Force)
            DeleteDirectory("haarcascade_frontalface_JHPJHP", "*.*", #PB_FileSystem_Force | #PB_FileSystem_Recursive)

            If FileSize("haarcascade_frontalface_JHPJHP.xml") > 0 : MessageBox_(0, "File locked: haarcascade_frontalface_JHPJHP.xml.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
            If FileSize("haarcascade_frontalface_JHPJHP") = -2 : MessageBox_(0, "Folder locked: haarcascade_frontalface_JHPJHP.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

          EndIf
        Case 72, 104
          If FileSize("haarcascade_frontalface_JHPJHP.xml") = -1
            If LoadXML(0, "haarcascade_frontalface_JHPJHP\cascade.xml")
              *Root = RootXMLNode(0)
              *Child = ChildXMLNode(*Root)
              *Node = ChildXMLNode(*Child)

              If GetXMLNodeName(*Node) = "cascade"
                SetXMLNodeName(*Node, "haarcascade_frontalface_JHPJHP")
                SetXMLAttribute(*Node, "type_id", "opencv-haar-classifier")
                SaveXML(0, "haarcascade_frontalface_JHPJHP.xml")
              EndIf
              FreeXML(0)
            EndIf
          EndIf

          If FileSize("haarcascade_frontalface_JHPJHP.xml") > 0
            face ! 1
            *cascade = cvLoad(haarcascade(face), #Null, #Null, #Null)
            x = 0 : y = 0 : width = 0 : height = 0
          Else
            face = 0
            MessageBox_(0, "Missing file: haarcascade_frontalface_JHPJHP.xml.", #CV_WINDOW_NAME, #MB_ICONERROR)
          EndIf
        Case 80, 112
          DeleteFile("trained/performance.txt", #PB_FileSystem_Force)
          DeleteDirectory("trained/tests", "*.*", #PB_FileSystem_Force)

          If FileSize("trained/performance.txt") > 0 : MessageBox_(0, "File locked: trained\performance.txt.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
          If FileSize("trained/tests") = -2 : MessageBox_(0, "Folder locked: trained\tests.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

          If FileSize("haarcascade_frontalface_JHPJHP.xml") > 0 And FileSize("trained/neg_train.txt") > 0 And FileSize("trained/positives/1.jpg") > 0
            ShowWindow_(hWnd, #SW_HIDE)
            RunProgram("opencv_createsamples.exe", "-img trained\positives\1.jpg -num " + Str(negCount) + " -bg trained\neg_train.txt -info trained\tests\test_train.txt -maxxangle 0.0 -maxyangle 0.0 -maxzangle 0.0 -maxidev 0 -bgcolor 0 -bgthresh 0 -w " + Str(whHaar) + " -h " + Str(whHaar), "", #PB_Program_Wait)

            If FileSize("trained/tests/test_train.txt") > 0
              performance = RunProgram("opencv_performance.exe", "-data haarcascade_frontalface_JHPJHP.xml -info trained\tests\test_train.txt -w " + Str(whHaar) + " -h " + Str(whHaar), "", #PB_Program_Open | #PB_Program_Read)

              If performance
                If OpenFile(1, "trained/performance.txt")
                  While ProgramRunning(performance)
                    If AvailableProgramOutput(performance) : WriteStringN(1, ReadProgramString(performance)) : EndIf
                  Wend
                  CloseProgram(performance)
                  CloseFile(1)

                  If ReadFile(1, "trained/tests/test_train.txt")
                    While Not Eof(1)
                      DeleteFile("trained/tests/" + ReadString(1, #PB_Ascii, 28))
                    Wend
                    CloseFile(1)
                  EndIf
                  RunProgram("notepad.exe", "trained\performance.txt", "")
                Else
                  MessageBox_(0, "Missing file: trained\performance.txt.", #CV_WINDOW_NAME, #MB_ICONERROR)
                EndIf
              EndIf
            Else
              MessageBox_(0, "Missing file: trained\tests\test_train.txt.", #CV_WINDOW_NAME, #MB_ICONERROR)
            EndIf
            Break
          Else
            If FileSize("haarcascade_frontalface_JHPJHP.xml") = -1
              MessageBox_(0, "Missing file: haarcascade_frontalface_JHPJHP.xml.", #CV_WINDOW_NAME, #MB_ICONERROR)
            ElseIf FileSize("trained/neg_train.txt") = -1
              MessageBox_(0, "Missing file: trained\neg_train.txt.", #CV_WINDOW_NAME, #MB_ICONERROR)
            Else
              MessageBox_(0, "Missing file: trained\positives\1.jpg.", #CV_WINDOW_NAME, #MB_ICONERROR)
            EndIf
          EndIf
        Case 83, 115
          If posCount > 0 And CaptureCV = #False
            If IsFile(0) : CloseFile(0) : EndIf

            RunProgram("opencv_createsamples.exe", "-info trained\pos_train.txt -vec trained\positives.vec -num " + Str(posCount) + " -w " + Str(whHaar) + " -h " + Str(whHaar), "", #PB_Program_Wait)
          Else
            If face = 0 : MessageBox_(0, "Positive frame count is zero.", #CV_WINDOW_NAME, #MB_ICONERROR) : Else : face = 0 : EndIf
          EndIf
        Case 84, 116
          If posCount > 0 And FileSize("trained/positives.vec") > 0
            If negCount > 0
              DeleteFile("haarcascade_frontalface_JHPJHP.xml", #PB_FileSystem_Force)

              If FileSize("haarcascade_frontalface_JHPJHP.xml") > 0 : MessageBox_(0, "File locked: haarcascade_frontalface_JHPJHP.xml.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

              DeleteDirectory("haarcascade_frontalface_JHPJHP", "*.*", #PB_FileSystem_Force | #PB_FileSystem_Recursive)

              If FileSize("haarcascade_frontalface_JHPJHP") = -2 : MessageBox_(0, "Folder locked: haarcascade_frontalface_JHPJHP.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf

              CreateDirectory("haarcascade_frontalface_JHPJHP")

              If FileSize("haarcascade_frontalface_JHPJHP") <> -2 : MessageBox_(0, "Cannot create folder: haarcascade_frontalface_JHPJHP.", #CV_WINDOW_NAME, #MB_ICONERROR) : Break : EndIf
              If IsFile(0) : CloseFile(0) : EndIf
              If posCount * 2 < negCount : negCount = posCount * 2 : EndIf

              RunProgram("opencv_traincascade.exe", "-data haarcascade_frontalface_JHPJHP -vec trained\positives.vec -bg trained\neg_train.txt -numPos " + Str(posCount * 0.9) + " -numNeg " + Str(negCount) + " -numStages " + Str(nStages) + " -precalcValBufSize 256 -precalcIdxBufSize 256 -baseFormatSave -featureType HAAR -w " + Str(whHaar) + " -h " + Str(whHaar) + " -minHitRate 0.999", "")
              Break
            Else
              MessageBox_(0, "Negative image count is zero.", #CV_WINDOW_NAME, #MB_ICONERROR)
            EndIf
          Else
            If face = 0
              If posCount = 0
                MessageBox_(0, "Positive frame count is zero.", #CV_WINDOW_NAME, #MB_ICONERROR)
              Else
                MessageBox_(0, "Missing samples file.", #CV_WINDOW_NAME, #MB_ICONERROR)
              EndIf
            Else
              face = 0
            EndIf
          EndIf
        Case 88, 120
          If face = 0
            posCount = 0
            cvReleaseVideoWriter(@*writer)
          Else
            face = 0
          EndIf
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV

  If IsFile(0) : CloseFile(0) : EndIf

  FreeMemory(*param)
  cvReleaseMemStorage(@*storage)
  cvReleaseHaarClassifierCascade(@*cascade)
  cvReleaseImage(@*resize)
  cvReleaseImage(@*gray)
  cvReleaseVideoWriter(@*writer)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\