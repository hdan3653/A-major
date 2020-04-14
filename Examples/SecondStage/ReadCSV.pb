; http://purebasic.fr/german/viewtopic.php?f=16&t=26590&hilit=ReadCSV&start=4
; https://www.purebasic.fr/german/viewtopic.php?f=16&t=26590&hilit=readcsv

; Edited 11/16/2019 to permit the quoted text to contain a doublequote, as per one specification,
;                  with the format being two doublequotes "" to indicate the text contains one doublequote character

; EnableExplicit

Structure CSVEntry
  List Item.s()
EndStructure

#DQuote = 34
#CR = 13
#LF = 10

; So you can select whether the quotes are part of the output string, or not.

#CSV_WithDoubleQuotes   = 0 ; add double quotes to the output string (default)
#CSV_WithoutDoubleQuotes = 1; remove double quotes from the output string

Procedure ReadCSV(*p.Character, separator.c, List lst.CSVEntry(), flags = #CSV_WithDoubleQuotes)
  Protected item.s
  Protected *p2.character = *p
  
  
  ClearList( lst() )
  
  If *p = 0 Or *p\c = 0
    ProcedureReturn ; empty string
  EndIf
  
  AddElement(lst())
  
  While *p\c <> 0
    While *p\c <> 0
      If *p\c = #DQuote                  ; DoubleQuote start
        If flags = #CSV_WithDoubleQuotes
          item + Chr(*p\c)            ; add starting DoubleQuote
        EndIf
        *p + SizeOf(Character)
        *p2 = *p + SizeOf(Character)
        While (*p\c <> 0 And *p\c <> #DQuote) Or (*p\c = #DQuote And *p2\c = #DQuote )        ; scan for DoubleQuote end,
                                                                                              ; OR a "DoubleQuote escaped" DoubleQuote
          If *p\c <> #LF And *p\c <> #CR                                                      ; do Not ADD cariage Return And line feed While IN string
            item + Chr(*p\c)
          EndIf
          If *p\c = #DQuote            ; can only get here if there's a double doublequote
            *p + SizeOf(Character)     ; Skip a dq
          EndIf                  
          *p + SizeOf(Character)
          *p2 = *p + SizeOf(Character)
        Wend
        If *p\c = #DQuote
          If flags = #CSV_WithDoubleQuotes
            item + Chr(*p\c)         ; add ending DoubleQuote
          EndIf
          *p + SizeOf(Character)
          
        EndIf
        Continue                     ; continue scanning
      ElseIf *p\c = separator        ; separator found. exit inner loop
        *p + SizeOf(Character)
        Break
      ElseIf *p\c = #LF Or *p\c = #CR         ; cariage return or line feed found outside string: Break
        Break
      Else                           ; other character found, so add it to current item
        item + Chr(*p\c)
        *p + SizeOf(Character)
      EndIf
    Wend
    
    AddElement(lst()\Item())               ; add current item to the list items      
    lst()\Item() = item
    item=""
    
    If *p\c = #CR                        ; for #CR$, #LF$, #CRLF$, #LFCR$:
      AddElement(lst())                  ; end of line found, so add a new list entry
      *p + SizeOf(Character)
      If *p\c = #LF
        *p + SizeOf(Character)
      EndIf
    ElseIf *p\c = #LF
      AddElement(lst())
      *p + SizeOf(Character)
      If *p\c = #CR
        *p + SizeOf(Character)
      EndIf
    EndIf
  Wend
  
  FirstElement(lst())
  If ListSize(lst())=1 And ListSize(lst()\Item())=0
    ClearList(lst())
  EndIf
EndProcedure

Procedure.i ReadCSVFile(filename.s, separator.c, List lst.CSVEntry(), flags = #CSV_WithDoubleQuotes)
  Protected file, *mem, format, line.s, stringpointer.i, result.i
  ClearList( lst() )
  file = ReadFile(#PB_Any,filename)
  If file
    format = ReadStringFormat(file)
    *mem = AllocateMemory((Lof(file)+10)*SizeOf(Character)) ; read file into memory, line by line
    If *mem
      stringpointer = *mem
      While Not Eof(file)
        line = ReadString(file,format)
        If Eof(file) = 0
          line + #LF$
        EndIf
        CopyMemoryString(@line,@stringpointer)
      Wend
      ReadCSV(*mem,separator,lst(),flags)                  ; call ReadCSV() on the memory
      result = #True
      FreeMemory(*mem)
    EndIf
    CloseFile(file)
  EndIf
  ProcedureReturn result
EndProcedure
