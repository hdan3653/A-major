# PureBasic plugin makefile example (Windows x86 only)
# To compile on Linux/OSX, replace the $(PB_VC8) line with 'gcc' and $PB_OBJ) with 'o'
# To compile Windows 64 bit, just use another env var for PB_VC8 and point to the 64 bit of cl.exe (and PUREBASIC_HOME to a 64 bit PureBasic)
#
TARGET = x86
LIBRARY = ImagePluginFAKE
LIBRARYFILE = $(PUREBASIC_HOME)\PureLibraries\$(LIBRARY)
DEPENDENCIES = ImageFAKE.h $(TARGET)/dummy $(PB_LIBRARIES)/PureLibrary.h $(PB_LIBRARIES)/FunctionPrototypes.h $(PB_LIBRARIES)/SystemBase/SystemBase.h
PB_OBJ = obj

# Add all your object list here, which are your C files in the output path
#
OBJECTS = $(TARGET)/ImageDecoderFAKE.$(PB_OBJ) \
          $(TARGET)/ImageEncoderFAKE.$(PB_OBJ) \


# Add all you unicode specific routine here (with the _UNICODE.obj postfix)
#
OBJECTS_UNICODE = 


# need to add one empty tab line after the target, otherwise it failes here!?
$(LIBRARY): $(LIBRARYFILE)
	

$(LIBRARYFILE) : $(LIBRARY).desc $(OBJECTS) $(OBJECTS_UNICODE)
	cp $(LIBRARY).Desc  $(TARGET)/$(LIBRARY).Desc
	$(PB_LIBRARIAN) /out:$(TARGET)/$(LIBRARY).lib $(OBJECTS) $(OBJECTS_UNICODE)
	$(PB_LIBRARYMAKER) $(TARGET)/$(LIBRARY).desc /TO $(PUREBASIC_HOME)/PureLibraries/


# General rules to compile all the files at once
#
$(TARGET)/%_UNICODE.$(PB_OBJ) : %.c $(DEPENDENCIES)
	$(PB_VC8) /O2 -DUNICODE /c $< /Fo$@

$(TARGET)/%.$(PB_OBJ) : %.c $(DEPENDENCIES)
	$(PB_VC8) /O2 /c $< /Fo$@



# Create the output directory (if not exists) where the obj will be created (note: without the "", mkdir fails on windows)
$(TARGET)/dummy:
	mkdir "$(TARGET)"
	touch $(TARGET)/dummy


clean:
	rm -f $(TARGET)/*.obj $(TARGET)/*.lib $(TARGET)/PureLibrariesMaker.log
