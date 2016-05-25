require "ffi"
require "pry"

module LibUI
  extend FFI::Library
  ffi_lib './libui.dylib'

  class InitOptions < FFI::Struct
    layout :size, :size_t
  end

  class Control < FFI::Struct
    layout :signature,      :uint32,
           :os_signature,   :uint32,
           :type_signature, :uint32,
           :destroy,        :pointer,
           :handle,         :pointer,
           :parent,         :pointer, #Control
           :set_parent,     :pointer, #Control
           :top_level,      :int,
           :visible,        :int,
           :show,           :pointer,
           :hide,           :pointer,
           :enabled,        :int,
           :enable,         :pointer,
           :disable,        :pointer
  end

  class Window < FFI::Struct
    layout :c, :pointer, #control
           :w, :pointer, #window
           :child, Control,
           :onClosing, :pointer
  end

  class Box < Control
  end
  
  class Checkbox < Control
  end

  class Menu < Control; end
  class MenuItem < Control; end
  class Group < Control; end
  class Button < Control; end
  class Label < Control; end
  class Separator < Control; end
  class DatePicker < Control; end
  class TimePicker < Control; end
  class DateTimePicker < Control; end
  class FontButton < Control; end
  class ColorButton < Control; end
  class SpinBox < Control; end
  class Slider < Control; end
  class ProgressBar < Control; end
  class Combobox < Control; end
  class EditableCombobox < Control; end
  class Radiobuttons < Control; end
  class Tab < Control; end

  attach_function :uiInit, [ InitOptions ], :string
  attach_function :uiControlShow, [ :pointer ], :void
  attach_function :uiMain, [], :void
  attach_function :uiQuit, [], :void
  attach_function :uiUninit, [], :void
  attach_function :uiFreeInitError, [:char], :void
  attach_function  :uiControlDestroy, [:pointer], :void

  #_UI_EXTERN uiWindow *uiNewWindow(const char *title, int width, int height, int hasMenubar);
  attach_function :uiNewWindow, [:string, :int, :int, :int], Window

  callback :quit_callback, [:pointer], :int
  attach_function :uiOnShouldQuit, [:quit_callback, :pointer ], :void
  attach_function :uiWindowOnClosing, [Window, :quit_callback, :pointer ], :void
  attach_function :uiWindowSetChild, [Window, Control], :void
  attach_function :uiWindowSetTitle, [Window, :string], :void
  attach_function :uiWindowSetMargined, [Window, :int], :void
  

  attach_function :uiNewHorizontalBox, [], Box
  attach_function :uiNewVerticalBox,   [], Box
  attach_function :uiBoxSetPadded, [Box, :int], :void
  attach_function :uiBoxAppend, [Box, Control, :int], :void

  attach_function :uiNewCheckbox, [:string], Checkbox

  #_UI_EXTERN void uiCheckboxOnToggled(uiCheckbox *c, void (*f)(uiCheckbox *c, void *data), void *data);
  callback :checkbox_toggle_callback, [:pointer], :int
  attach_function :uiCheckboxOnToggled, [Checkbox, :checkbox_toggle_callback, :pointer], :void
  attach_function :uiCheckboxChecked, [Checkbox], :int
  attach_function :uiCheckboxSetText, [Checkbox, :string], :void

  attach_function :uiNewMenu, [:string], Menu
  attach_function :uiMenuAppendItem, [Menu, :string], MenuItem
  attach_function :uiMenuItemDisable, [MenuItem], :void
  callback :menu_item_clicked, [:pointer], :int
  attach_function :uiMenuItemOnClicked, [Menu, :menu_item_clicked, :pointer], :void
  attach_function :uiMenuAppendQuitItem, [Menu], :void
  attach_function :uiMenuAppendCheckItem, [Menu, :string], :void
  attach_function :uiMenuAppendSeparator, [Menu], :void
  attach_function :uiMenuAppendPreferencesItem, [Menu], MenuItem
  attach_function :uiMenuAppendAboutItem, [Menu], MenuItem

  attach_function :uiNewGroup, [:string], Group
  attach_function :uiGroupSetMargined, [Group, :int], :void
  attach_function :uiGroupSetChild, [Group, :pointer], :void

  attach_function :uiNewButton, [:string], Button

  attach_function :uiNewLabel, [:string], Label
  attach_function :uiNewHorizontalSeparator, [], Separator
  attach_function :uiNewDatePicker, [], DatePicker
  attach_function :uiNewTimePicker, [], TimePicker
  attach_function :uiNewDateTimePicker, [], DateTimePicker
  attach_function :uiNewFontButton, [], FontButton
  attach_function :uiNewColorButton, [], ColorButton
  attach_function :uiNewSpinbox, [:int, :int], SpinBox
  attach_function :uiNewSlider, [:int, :int], Slider
  attach_function :uiNewProgressBar, [], ProgressBar

  attach_function :uiNewCombobox, [], Combobox
  attach_function :uiComboboxAppend, [Combobox, :string], :void
  attach_function :uiNewEditableCombobox, [], EditableCombobox

  attach_function :uiNewRadioButtons, [], Radiobuttons
  attach_function :uiRadioButtonsAppend, [Radiobuttons, :string], Radiobuttons

  attach_function :uiNewTab, [], Tab
  attach_function :uiTabAppend, [Tab, :string, Control], :void
end



options =  LibUI::InitOptions.new
options[:size] = 0

init =  LibUI.uiInit(options)

if init != nil
  puts "error"
  puts LibUI.uiFreeInitError(init)
end

should_quit = Proc.new do |ptr|
  puts "QUITTING!"
  LibUI.uiControlDestroy(MAIN_WINDOW)
  LibUI.uiQuit
  0
end

checkbox_toggle = Proc.new do |ptr|
  checked = LibUI.uiCheckboxChecked(ptr) == 1
  LibUI.uiWindowSetTitle(MAIN_WINDOW, "Checkbox is #{checked}")
  LibUI.uiCheckboxSetText(ptr, "I am the checkbox (#{checked})")
end

open_menu_item_clicked = Proc.new do |ptr|
  puts "Clicked 'Open'"
end

save_menu_item_clicked = Proc.new do |ptr|
  puts "Clicked 'Save'"
end


menu = LibUI.uiNewMenu("File")
open_menu_item = LibUI.uiMenuAppendItem(menu, "Open")
LibUI.uiMenuItemOnClicked(open_menu_item, open_menu_item_clicked, nil)
save_menu_item = LibUI.uiMenuAppendItem(menu, "Save")
LibUI.uiMenuItemOnClicked(save_menu_item, save_menu_item_clicked, nil)
LibUI.uiMenuAppendQuitItem(menu)
LibUI.uiOnShouldQuit(should_quit, nil)

edit_menu = LibUI.uiNewMenu("Edit")
LibUI.uiMenuAppendCheckItem(edit_menu, "Checkable Item")
LibUI.uiMenuAppendSeparator(edit_menu)

disabled_item = LibUI.uiMenuAppendItem(edit_menu, "Disabled Item");
LibUI.uiMenuItemDisable(disabled_item);

preferences = LibUI.uiMenuAppendPreferencesItem(menu)

help_menu = LibUI.uiNewMenu("Help")
LibUI.uiMenuAppendItem(help_menu, "Help")
LibUI.uiMenuAppendAboutItem(help_menu)


#checkbox = LibUI.uiNewCheckbox("I am the checkbox")
#LibUI.uiCheckboxOnToggled(checkbox, checkbox_toggle, nil)
vbox = LibUI.uiNewVerticalBox
hbox = LibUI.uiNewHorizontalBox
LibUI.uiBoxSetPadded(vbox, 1)
LibUI.uiBoxSetPadded(hbox, 1)

#LibUI.uiBoxAppend(vbox, checkbox , 0)
LibUI.uiBoxAppend(vbox, hbox , 1)

group = LibUI.uiNewGroup("Basic Controls")
LibUI.uiGroupSetMargined(group, 1)
LibUI.uiBoxAppend(hbox, group, 0)

inner = LibUI.uiNewVerticalBox
LibUI.uiBoxSetPadded(inner, 1)
LibUI.uiGroupSetChild(group, inner)

LibUI.uiBoxAppend(inner, LibUI.uiNewButton("Button"), 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewCheckbox("Checkbox"), 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewLabel("Label"), 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewHorizontalSeparator, 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewDatePicker, 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewTimePicker, 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewDateTimePicker, 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewFontButton, 0)
LibUI.uiBoxAppend(inner, LibUI.uiNewColorButton, 0)

inner2 = LibUI.uiNewVerticalBox
LibUI.uiBoxSetPadded(inner2, 1)
LibUI.uiBoxAppend(hbox, inner2, 1)

group = LibUI.uiNewGroup("Numbers")
LibUI.uiGroupSetMargined(group, 1)
LibUI.uiBoxAppend(inner2, group, 0)

inner = LibUI.uiNewVerticalBox
LibUI.uiBoxSetPadded(inner, 1)
LibUI.uiGroupSetChild(group, inner)

spinbox = LibUI.uiNewSpinbox(0, 100)
#LibUI.uiSpinboxOnChanged(spinbox, onSpinboxChanged, nil)
LibUI.uiBoxAppend(inner, spinbox, 0);

slider = LibUI.uiNewSlider(0, 100)
#libUIuiSliderOnChanged(slider, onSliderChanged, nil)
LibUI.uiBoxAppend(inner, slider, 0)

progressbar = LibUI.uiNewProgressBar
LibUI.uiBoxAppend(inner, progressbar, 0)

group = LibUI.uiNewGroup("Lists")
LibUI.uiGroupSetMargined(group, 1)
LibUI.uiBoxAppend(inner2, group, 0)

inner = LibUI.uiNewVerticalBox
LibUI.uiBoxSetPadded(inner, 1)
LibUI.uiGroupSetChild(group, inner)

cbox = LibUI.uiNewCombobox
LibUI.uiComboboxAppend(cbox, "Combobox Item 1")
LibUI.uiComboboxAppend(cbox, "Combobox Item 2")
LibUI.uiComboboxAppend(cbox, "Combobox Item 3")
LibUI.uiBoxAppend(inner, cbox, 0)

cbox = LibUI.uiNewEditableCombobox
LibUI.uiComboboxAppend(cbox, "Editable Item 1")
LibUI.uiComboboxAppend(cbox, "Editable Item 2")
LibUI.uiComboboxAppend(cbox, "Editable Item 3")
LibUI.uiBoxAppend(inner, cbox, 0)

rb = LibUI.uiNewRadioButtons
LibUI.uiRadioButtonsAppend(rb, "Radio Button 1")
LibUI.uiRadioButtonsAppend(rb, "Radio Button 2")
LibUI.uiRadioButtonsAppend(rb, "Radio Button 3")
LibUI.uiBoxAppend(inner, rb, 1)

tab = LibUI.uiNewTab
LibUI.uiTabAppend(tab, "Page 1", LibUI.uiNewHorizontalBox)
LibUI.uiTabAppend(tab, "Page 2", LibUI.uiNewHorizontalBox)
LibUI.uiTabAppend(tab, "Page 3", LibUI.uiNewHorizontalBox)
LibUI.uiBoxAppend(inner2, tab, 1)


MAIN_WINDOW = LibUI.uiNewWindow("hello world", 600, 600, 1)
LibUI.uiWindowSetMargined(MAIN_WINDOW, 1)
LibUI.uiWindowSetChild(MAIN_WINDOW, vbox)

LibUI.uiWindowOnClosing(MAIN_WINDOW,should_quit, nil)
puts LibUI.uiControlShow(MAIN_WINDOW)

LibUI.uiMain
LibUI.uiQuit
