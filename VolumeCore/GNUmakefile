include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = VolumeCore
OBJCFLAGS = -include OtherSources/VolumeCore_Prefix.pch
ADDITIONAL_INCLUDE_DIRS = -IClasses/ -IOtherSources/
ADDITIONAL_OBJC_LIBS = -lGL -lGLU

VolumeCore_HEADERS = Classes/CocoaOpenGLView.h Classes/TransferFunctionView.h Classes/VoxelDocument.h  OtherSources/VolumeCore.h OtherSources/opengl_linux.h
VolumeCore_C_FILES = OtherSources/opengl_linux.c
VolumeCore_OBJC_FILES = OtherSources/main.m Classes/CocoaOpenGLView.m Classes/TransferFunctionView.m Classes/VoxelDocument.m
VolumeCore_RESOURCE_FILES = Resources/2d.frag Resources/2d.vert Resources/3d.frag Resources/3d.vert Resources/raypos.frag Resources/raypos.vert Resources/stagbeetle277x277x164.dat Resources/XMasTree.dat Resources/English.lproj/MainMenu.xib Resources/NoHud/VoxelDocument.nib Resources/VolumeCore.icns Resources/VolumeCoreDocument.icns Resources/English.lproj/Credits.rtf
VolumeCore_MAIN_MODEL_FILE = MainMenu.xib

include $(GNUSTEP_MAKEFILES)/application.make
