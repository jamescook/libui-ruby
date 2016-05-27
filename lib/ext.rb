require "ffi"

module LibUI
  module Ext
    extend FFI::Library
    ffi_lib Config.instance.library_path

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

    class Box              < Control;end
    class Checkbox         < Control;end
    class Menu             < Control; end
    class MenuItem         < Control; end
    class Group            < Control; end
    class Button           < Control; end
    class Label            < Control; end
    class Separator        < Control; end
    class DatePicker       < Control; end
    class TimePicker       < Control; end
    class DateTimePicker   < Control; end
    class FontButton       < Control; end
    class ColorButton      < Control; end
    class SpinBox          < Control; end
    class Slider           < Control; end
    class ProgressBar      < Control; end
    class Combobox         < Control; end
    class EditableCombobox < Control; end
    class Radiobuttons     < Control; end
    class Tab              < Control; end
    class TextEntry        < Control; end

    attach_function :uiInit,            [ InitOptions ], :string
    attach_function :uiControlShow,     [ :pointer ],    :void
    attach_function :uiMain,            [],              :void
    attach_function :uiQuit,            [],              :void
    attach_function :uiUninit,          [],              :void
    attach_function :uiFreeInitError,   [:char],         :void
    attach_function :uiControlDestroy,  [:pointer],      :void


    callback :quit_callback,              [:pointer], :int
    attach_function :uiNewWindow,
      [:string,
       :int,
       :int,
       :int],
       Window
    attach_function :uiOnShouldQuit,
      [:quit_callback, # proc/lambda
       :pointer ],
       :void
    attach_function :uiWindowOnClosing,
      [Window,
       :quit_callback, # proc/lambda
       :pointer ],
       :void
    attach_function :uiWindowSetChild, [Window, Control], :void
    attach_function :uiWindowSetTitle,
      [Window,
       :string], # title
       :void
    attach_function :uiWindowSetMargined,
      [Window, 
       :int], # margin value
       :void
    
    attach_function :uiNewHorizontalBox, [], Box
    attach_function :uiNewVerticalBox,   [], Box
    attach_function :uiBoxSetPadded,     [Box, :int],          :void
    attach_function :uiBoxAppend,        [Box, Control, :int], :void

    callback :checkbox_toggle_callback,   [:pointer],          :int
    attach_function :uiNewCheckbox,       [:string],           Checkbox
    attach_function :uiCheckboxChecked,   [Checkbox],          :int
    attach_function :uiCheckboxSetText,   [Checkbox, :string], :void
    attach_function :uiCheckboxOnToggled,
      [Checkbox,
       :checkbox_toggle_callback,
       :pointer],
       :void

    callback :menu_item_clicked, [:pointer], :int
    attach_function :uiNewMenu,                   [:string],       Menu
    attach_function :uiMenuAppendItem,            [Menu, :string], MenuItem
    attach_function :uiMenuAppendPreferencesItem, [Menu],          MenuItem
    attach_function :uiMenuAppendAboutItem,       [Menu],          MenuItem
    attach_function :uiMenuItemDisable,           [MenuItem],      :void
    attach_function :uiMenuAppendQuitItem,        [Menu],          :void
    attach_function :uiMenuAppendCheckItem,       [Menu, :string], :void
    attach_function :uiMenuAppendSeparator,       [Menu],          :void
    attach_function :uiMenuItemOnClicked,
      [Menu,
       :menu_item_clicked,
       :pointer],
       :void

    attach_function :uiNewGroup,         [:string],         Group
    attach_function :uiGroupSetMargined, [Group, :int],     :void
    attach_function :uiGroupMargined,    [Group],           :int
    attach_function :uiGroupSetChild,    [Group, :pointer], :void
    attach_function :uiGroupSetTitle,    [Group, :string],  :void

    attach_function :uiNewDatePicker,          [],           DatePicker
    attach_function :uiNewTimePicker,          [],           TimePicker
    attach_function :uiNewDateTimePicker,      [],           DateTimePicker
    attach_function :uiNewFontButton,          [],           FontButton
    attach_function :uiNewColorButton,         [],           ColorButton
    attach_function :uiNewHorizontalSeparator, [],           Separator
    attach_function :uiNewProgressBar,         [],           ProgressBar
    attach_function :uiNewLabel,               [:string],    Label
    attach_function :uiLabelSetText,           [:string],    :void
    attach_function :uiLabelText,              [Label],      :string

    callback :button_clicked_callback,  [:pointer], :int
    attach_function :uiNewButton,       [:string], Button
    attach_function :uiButtonSetText,   [Button, :string], :void
    attach_function :uiButtonOnClicked, [Button, :button_clicked_callback, :pointer], :void

    callback :slider_changed_callback,         [:pointer],           :int
    attach_function :uiNewSlider,              [:intmax_t, :intmax_t], Slider
    attach_function :uiSliderSetValue,         [Slider, :intmax_t],    :void
    attach_function :uiSliderValue,            [Slider],               :intmax_t
    attach_function :uiSliderOnChanged, [
      Slider,
      :slider_changed_callback,
      :pointer
    ], :void

    callback :spinbox_changed_callback,        [:pointer],           :int
    attach_function :uiNewSpinbox,             [:int, :int],         SpinBox
    attach_function :uiSpinboxValue,           [SpinBox],            :intmax_t
    attach_function :uiSpinboxSetValue,        [SpinBox, :intmax_t], :void
    attach_function :uiSpinboxOnChanged, [
      SpinBox,
      :spinbox_changed_callback,
      :pointer
    ], :void

    callback :combobox_selected_callback,   [:pointer],          :int
    attach_function :uiNewCombobox,         [],                  Combobox
    attach_function :uiComboboxSelected,    [Combobox],          :intmax_t
    attach_function :uiComboboxAppend,      [Combobox, :string], :void
    attach_function :uiComboboxSetSelected, [Combobox, :intmax_t], :void # int is the index
    attach_function :uiComboboxOnSelected,  [
      Combobox,
      :combobox_selected_callback,
      :pointer
    ], :void

    attach_function :uiNewEditableCombobox,       [], EditableCombobox

    attach_function :uiNewRadioButtons,     [],                      Radiobuttons
    attach_function :uiRadioButtonsAppend,  [Radiobuttons, :string], Radiobuttons

    attach_function :uiNewTab,    [],                      Tab
    attach_function :uiTabAppend, [Tab, :string, Control], :void
    attach_function :uiTabInsertAt, [
      Tab, 
      :string,    # the tab 'name'
      :uintmax_t, # "before"
      Control
    ], :void

    attach_function :uiTabDelete, [
      Tab,
      :uintmax_t # index 
     ], :void

    attach_function :uiTabNumPages, [Tab], :uintmax_t
    attach_function :uiTabMargined, [
      Tab,
      :uintmax_t # the 'page'
    ], :int
    
    attach_function :uiTabSetMargined, [
      Tab,
      :uintmax_t, # 'page'
      :int  # 'margined'
    ], :void


    attach_function :uiNewEntry,         [],                   TextEntry
    attach_function :uiEntrySetText,     [TextEntry, :string], TextEntry
    attach_function :uiEntryText,        [TextEntry],          :string
    attach_function :uiEntryReadOnly,    [TextEntry],          :int
    attach_function :uiEntrySetReadOnly, [TextEntry],          :void
    callback :text_entry_on_change, [:pointer], :int
    attach_function :uiEntryOnChanged,
      [TextEntry,
       :text_entry_on_change,
       :pointer ],
       :void

    attach_function :uiMsgBox, [Window, :string, :string], :void # title and description
    attach_function :uiMsgBoxError, [Window, :string, :string], :void # title and description
  end
end
