require "libui"

options =  LibUI::Ext::InitOptions.new
init    =  LibUI::Ext.uiInit(options)

if init != nil
  puts "error"
  puts LibUI::Ext.uiFreeInitError(init)
end

should_quit = Proc.new do |ptr|
  puts "QUITTING!"
  LibUI::Ext.uiControlDestroy(MAIN_WINDOW)
  LibUI::Ext.uiQuit
  0
end

checkbox_toggle = Proc.new do |ptr|
  checked = LibUI::Ext.uiCheckboxChecked(ptr) == 1
  LibUI::Ext.uiWindowSetTitle(MAIN_WINDOW, "Checkbox is #{checked}")
  LibUI::Ext.uiCheckboxSetText(ptr, "I am the checkbox (#{checked})")
end

open_menu_item_clicked = Proc.new do |ptr|
  puts "Clicked 'Open'"
end

save_menu_item_clicked = Proc.new do |ptr|
  puts "Clicked 'Save'"
end

# Create 'File' menu with a few items and callbacks
# when the items are clicked
menu = LibUI::Ext.uiNewMenu("File")
open_menu_item = LibUI::Ext.uiMenuAppendItem(menu, "Open")
LibUI::Ext.uiMenuItemOnClicked(open_menu_item, open_menu_item_clicked, nil)
save_menu_item = LibUI::Ext.uiMenuAppendItem(menu, "Save")
LibUI::Ext.uiMenuItemOnClicked(save_menu_item, save_menu_item_clicked, nil)
LibUI::Ext.uiMenuAppendQuitItem(menu)
LibUI::Ext.uiOnShouldQuit(should_quit, nil)

# Create 'Edit' menu
edit_menu = LibUI::Ext.uiNewMenu("Edit")
LibUI::Ext.uiMenuAppendCheckItem(edit_menu, "Checkable Item")
LibUI::Ext.uiMenuAppendSeparator(edit_menu)
disabled_item = LibUI::Ext.uiMenuAppendItem(edit_menu, "Disabled Item");
LibUI::Ext.uiMenuItemDisable(disabled_item);

preferences = LibUI::Ext.uiMenuAppendPreferencesItem(menu)

help_menu = LibUI::Ext.uiNewMenu("Help")
LibUI::Ext.uiMenuAppendItem(help_menu, "Help")
LibUI::Ext.uiMenuAppendAboutItem(help_menu)


vbox = LibUI::Ext.uiNewVerticalBox
hbox = LibUI::Ext.uiNewHorizontalBox
LibUI::Ext.uiBoxSetPadded(vbox, 1)
LibUI::Ext.uiBoxSetPadded(hbox, 1)

LibUI::Ext.uiBoxAppend(vbox, hbox , 1)

group = LibUI::Ext.uiNewGroup("Basic Controls")
LibUI::Ext.uiGroupSetMargined(group, 1)
LibUI::Ext.uiBoxAppend(hbox, group, 0)

inner = LibUI::Ext.uiNewVerticalBox
LibUI::Ext.uiBoxSetPadded(inner, 1)
LibUI::Ext.uiGroupSetChild(group, inner)

button = LibUI::Ext.uiNewButton("Button")
button_clicked_callback = Proc.new do |ptr|
  LibUI::Ext.uiMsgBox(MAIN_WINDOW, "Information", "You clicked the button")
end

LibUI::Ext.uiButtonOnClicked(button, button_clicked_callback, nil)
LibUI::Ext.uiBoxAppend(inner, button, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewCheckbox("Checkbox"), 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewLabel("Label"), 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewHorizontalSeparator, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewDatePicker, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewTimePicker, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewDateTimePicker, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewFontButton, 0)
LibUI::Ext.uiBoxAppend(inner, LibUI::Ext.uiNewColorButton, 0)

inner2 = LibUI::Ext.uiNewVerticalBox
LibUI::Ext.uiBoxSetPadded(inner2, 1)
LibUI::Ext.uiBoxAppend(hbox, inner2, 1)

group = LibUI::Ext.uiNewGroup("Numbers")
LibUI::Ext.uiGroupSetMargined(group, 1)
LibUI::Ext.uiBoxAppend(inner2, group, 0)

inner = LibUI::Ext.uiNewVerticalBox
LibUI::Ext.uiBoxSetPadded(inner, 1)
LibUI::Ext.uiGroupSetChild(group, inner)

spinbox = LibUI::Ext.uiNewSpinbox(0, 100)
spinbox_changed_callback = Proc.new do |ptr|
  puts "New Spinbox value: #{LibUI::Ext.uiSpinboxValue(ptr)}"
end
LibUI::Ext.uiSpinboxSetValue(spinbox,42)
LibUI::Ext.uiSpinboxOnChanged(spinbox, spinbox_changed_callback, nil)
LibUI::Ext.uiBoxAppend(inner, spinbox, 0);

slider = LibUI::Ext.uiNewSlider(0, 100)
slider_changed_callback = Proc.new do |ptr|
  puts "New Slider value: #{LibUI::Ext.uiSliderValue(ptr)}"
end
LibUI::Ext.uiSliderOnChanged(slider, slider_changed_callback, nil)
LibUI::Ext.uiBoxAppend(inner, slider, 0)

progressbar = LibUI::Ext.uiNewProgressBar
LibUI::Ext.uiBoxAppend(inner, progressbar, 0)

group = LibUI::Ext.uiNewGroup("Lists")
LibUI::Ext.uiGroupSetMargined(group, 1)
LibUI::Ext.uiBoxAppend(inner2, group, 0)

inner = LibUI::Ext.uiNewVerticalBox
LibUI::Ext.uiBoxSetPadded(inner, 1)
LibUI::Ext.uiGroupSetChild(group, inner)

combobox_selected_callback = Proc.new do |ptr|
  puts "New combobox selection: #{LibUI::Ext.uiComboboxSelected(ptr)}"
end
cbox = LibUI::Ext.uiNewCombobox
LibUI::Ext.uiComboboxAppend(cbox, "Combobox Item 1")
LibUI::Ext.uiComboboxAppend(cbox, "Combobox Item 2")
LibUI::Ext.uiComboboxAppend(cbox, "Combobox Item 3")
LibUI::Ext.uiBoxAppend(inner, cbox, 0)
LibUI::Ext.uiComboboxOnSelected(cbox, combobox_selected_callback, nil)

ebox = LibUI::Ext.uiNewEditableCombobox
LibUI::Ext.uiEditableComboboxAppend(ebox, "Editable Item 1")
LibUI::Ext.uiEditableComboboxAppend(ebox, "Editable Item 2")
LibUI::Ext.uiEditableComboboxAppend(ebox, "Editable Item 3")
LibUI::Ext.uiBoxAppend(inner, ebox, 0)

rb = LibUI::Ext.uiNewRadioButtons
LibUI::Ext.uiRadioButtonsAppend(rb, "Radio Button 1")
LibUI::Ext.uiRadioButtonsAppend(rb, "Radio Button 2")
LibUI::Ext.uiRadioButtonsAppend(rb, "Radio Button 3")
LibUI::Ext.uiBoxAppend(inner, rb, 1)

tab = LibUI::Ext.uiNewTab
hbox1 = LibUI::Ext.uiNewHorizontalBox 
LibUI::Ext.uiTabAppend(tab, "Page 1", hbox1)
LibUI::Ext.uiTabAppend(tab, "Page 2", LibUI::Ext.uiNewHorizontalBox)
LibUI::Ext.uiTabAppend(tab, "Page 3", LibUI::Ext.uiNewHorizontalBox)
LibUI::Ext.uiBoxAppend(inner2, tab, 1)

text_changed_callback = Proc.new do |ptr|
  puts "Current textbox data: '#{LibUI::Ext.uiEntryText(ptr)}'"
end

text_entry = LibUI::Ext.uiNewEntry
LibUI::Ext.uiEntrySetText text_entry, "Please enter your feelings"
LibUI::Ext.uiEntryOnChanged(text_entry, text_changed_callback, nil)
LibUI::Ext.uiBoxAppend(hbox1, text_entry, 1)

MAIN_WINDOW = LibUI::Ext.uiNewWindow("hello world", 600, 600, 1)
LibUI::Ext.uiWindowSetMargined(MAIN_WINDOW, 1)
LibUI::Ext.uiWindowSetChild(MAIN_WINDOW, vbox)

LibUI::Ext.uiWindowOnClosing(MAIN_WINDOW,should_quit, nil)
LibUI::Ext.uiControlShow(MAIN_WINDOW)

LibUI::Ext.uiMain
LibUI::Ext.uiQuit
