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
    attach_function :uiGroupSetChild,    [Group, :pointer], :void

    attach_function :uiNewDatePicker,          [],           DatePicker
    attach_function :uiNewTimePicker,          [],           TimePicker
    attach_function :uiNewDateTimePicker,      [],           DateTimePicker
    attach_function :uiNewFontButton,          [],           FontButton
    attach_function :uiNewColorButton,         [],           ColorButton
    attach_function :uiNewHorizontalSeparator, [],           Separator
    attach_function :uiNewProgressBar,         [],           ProgressBar
    attach_function :uiNewButton,              [:string],    Button
    attach_function :uiNewLabel,               [:string],    Label
    attach_function :uiNewSpinbox,             [:int, :int], SpinBox
    attach_function :uiNewSlider,              [:int, :int], Slider

    attach_function :uiNewCombobox,         [],                  Combobox
    attach_function :uiComboboxAppend,      [Combobox, :string], :void
    attach_function :uiNewEditableCombobox, [],                  EditableCombobox

    attach_function :uiNewRadioButtons,     [],                      Radiobuttons
    attach_function :uiRadioButtonsAppend,  [Radiobuttons, :string], Radiobuttons

    attach_function :uiNewTab,    [],                      Tab
    attach_function :uiTabAppend, [Tab, :string, Control], :void
  end
end
