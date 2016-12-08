require "ffi"

module LibUI
  module Ext
    extend FFI::Library
    ffi_lib Config.instance.library_path

    DEFAULT_MITER_LIMIT = 10

    class InitOptions < FFI::Struct
      layout :size, :size_t
    end

    class DrawContext < FFI::Struct
      layout :c, :pointer
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
   
    class Box              < Control; end
    class Checkbox         < Control; end
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
    class Area             < Control; end
    class DrawPath         < Control; end
    class TextFont         < Control; end
    class TextLayout       < Control; end

    class Window < FFI::Struct
      layout :c, :pointer, #control
             :w, :pointer, #window
             :child, Control,
             :onClosing, :pointer
    end

    class AreaDrawParams < FFI::Struct
      layout :draw_context, :pointer, #DrawContext, uiDrawContext
        :width, :double,
        :height, :double,
        :clip_x, :double,
        :clip_y, :double,
        :clip_width, :double,
        :clip_height, :double
    end

    class AreaHandler < FFI::Struct
      # void (*Draw)(uiAreaHandler *, uiArea *, uiAreaDrawParams *);
      layout :draw_event, callback([
        LibUI::Ext::AreaHandler.ptr,
        LibUI::Ext::Area,
        LibUI::Ext::AreaDrawParams.ptr], :void),
        # void (*MouseEvent)(uiAreaHandler *, uiArea *, uiAreaMouseEvent *);
        :mouse_event, callback([:pointer, :pointer, :pointer], :void),
        #	void (*MouseCrossed)(uiAreaHandler *, uiArea *, int left);
        :mouse_crossed, callback([:pointer, :pointer, :int], :void),
        # void (*DragBroken)(uiAreaHandler *, uiArea *);
        :drag_broken, callback([:pointer, :pointer], :void),
        # int (*KeyEvent)(uiAreaHandler *, uiArea *, uiAreaKeyEvent *);
        :key_event, callback([:pointer, :pointer, :pointer], :int)
    end
    KEY_MODIFIERS = enum(:ctrl, 1 << 0, :alt, 1 << 1, :shift, 1 << 2, :super, 1 << 3)
    LINE_CAPS  = enum(:flat, :round, :square)
    LINE_JOINS = enum(:miter, :round, :bevel)
    TEXT_WEIGHTS = enum(:thin,
      :ultra_light,
      :light, :book,
      :normal,
      :medium,
      :semi_bold,
      :bold,
      :ultra_bold,
      :heavy,
      :ultra_heavy
    )

    TEXT_ITALIC = enum(:normal, :oblique, :italic)
    TEXT_STRETCH = enum(:ultra_condensed,
      :extra_condensed,
      :condensed,
      :semi_condensed,
      :normal,
      :semi_expanded,
      :expanded,
      :extra_expanded,
      :ultra_expanded
    )

    class AreaMouseEvent < FFI::Struct
      layout :x,      :double,
        :y,           :double,
        :area_width,  :double,
        :area_height, :double,
        :down,        :ulong_long,
        :up,          :ulong_long,
        :count,       :ulong_long,
        :modifiers,   KEY_MODIFIERS,
        :held1to64,   :ulong_long
    end

    class FontFamilies < FFI::Struct
      layout :ff, :pointer
    end

    class FontDescriptor < FFI::Struct
      layout :family, :string,
        :size, :double,
        :weight, TEXT_WEIGHTS,
        :italic, TEXT_ITALIC,
        :stretch, TEXT_STRETCH
    end

    class FontMetrics < FFI::Struct
      layout :ascent, :double,
        :descent, :double,
        :leading, :double,
        :underline_pos, :double,
        :underline_thickness, :double
    end

    class DrawStrokeParams < FFI::Struct
      layout :cap, LINE_CAPS,
        :join, LINE_JOINS,
        :thickness, :double,
        :miter_limit, :double,
        :dashes, :pointer, #double?
        :num_dashes, :size_t,
        :dash_phase, :double
    end

    BRUSH_TYPES = enum(:solid, :linear_gradient, :radial_gradient, :image)
    FILL_MODES  = enum(:winding, :alternate)

    class DrawBrush < FFI::Struct
      layout :type,  BRUSH_TYPES,
             :red,   :double,
             :green, :double,
             :blue,  :double,
             :alpha, :double,

             :x0, :double, # linear: start X, radial: start X
             :y0, :double, # linear: start Y, radial: start Y
             :x1, :double, # linear: end X, radial: outer circle center X
             :y1, :double, # linear: end Y, radial: outer circle center Y
             :outer_radius, :double, # radial gradients only
             :stops, :pointer, # pointer to uiDrawBrushGradientStop
             :num_stops, :size_t
    end

    class DrawMatrix < FFI::Struct
      layout :m11, :double,
        :m12, :double,
        :m21, :double,
        :m22, :double,
        :m31, :double,
        :m32, :double
    end

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
    attach_function :uiNewHorizontalSeparator, [],           Separator
    attach_function :uiNewProgressBar,         [],           ProgressBar

    attach_function :uiNewColorButton,         [],           ColorButton
    attach_function :uiColorButtonColor, [
      ColorButton,
      :pointer, #red, double
      :pointer, #green, double
      :pointer, #blue, double
      :pointer #alpha, double
    ], :void

    attach_function :uiColorButtonSetColor, [
      ColorButton,
      :double,  #red
      :double,  #green
      :double,  #blue
      :double #alpha
    ], :void
    callback :color_changed_callback, [:pointer], :int
    attach_function :uiColorButtonOnChanged,
      [ColorButton,
       :color_changed_callback,
       :pointer
     ], :void
    
    attach_function :uiNewLabel,               [:string],    Label
    attach_function :uiLabelSetText,           [:string],    :void
    attach_function :uiLabelText,              [Label],      :string

    callback :button_clicked_callback,  [:pointer], :int
    attach_function :uiNewButton,       [:string], Button
    attach_function :uiButtonSetText,   [Button, :string], :void
    attach_function :uiButtonOnClicked, [Button, :button_clicked_callback, :pointer], :void

    callback :slider_changed_callback,         [:pointer],           :int
    attach_function :uiNewSlider,              [:long_long, :long_long], Slider
    attach_function :uiSliderSetValue,         [Slider, :long_long],    :void
    attach_function :uiSliderValue,            [Slider],               :long_long
    attach_function :uiSliderOnChanged, [
      Slider,
      :slider_changed_callback,
      :pointer
    ], :void

    callback :spinbox_changed_callback,        [:pointer],           :int
    attach_function :uiNewSpinbox,             [:int, :int],         SpinBox
    attach_function :uiSpinboxValue,           [SpinBox],            :long_long
    attach_function :uiSpinboxSetValue,        [SpinBox, :long_long], :void
    attach_function :uiSpinboxOnChanged, [
      SpinBox,
      :spinbox_changed_callback,
      :pointer
    ], :void

    callback :combobox_selected_callback,   [:pointer],          :int
    attach_function :uiNewCombobox,         [],                  Combobox
    attach_function :uiComboboxSelected,    [Combobox],          :long_long
    attach_function :uiComboboxAppend,      [Combobox, :string], :void
    attach_function :uiComboboxSetSelected, [Combobox, :long_long], :void # int is the index
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
      :ulong_long, # "before"
      Control
    ], :void

    attach_function :uiTabDelete, [
      Tab,
      :ulong_long # index 
     ], :void

    attach_function :uiTabNumPages, [Tab], :ulong_long
    attach_function :uiTabMargined, [
      Tab,
      :ulong_long # the 'page'
    ], :int
    
    attach_function :uiTabSetMargined, [
      Tab,
      :ulong_long, # 'page'
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

    attach_function :uiNewArea, [AreaHandler], Area
    attach_function :uiAreaQueueRedrawAll, [Area], :void

    attach_function :uiDrawNewPath, [FILL_MODES], DrawPath
    
    attach_function :uiDrawPathAddRectangle, [
      DrawPath,
      :double, #x
      :double, #y
      :double, #width
      :double  #height
    ], :void
    attach_function :uiDrawPathEnd, [DrawPath], :void
    #_UI_EXTERN void uiDrawFill(uiDrawContext *c, uiDrawPath *path, uiDrawBrush *b);
    attach_function :uiDrawFill, [:pointer, DrawPath, DrawBrush], :void
    attach_function :uiDrawFreePath, [DrawPath], :void
    attach_function :uiDrawPathNewFigure, [DrawPath, :double, :double], :void # x and y
    attach_function :uiDrawPathLineTo, [DrawPath, :double, :double], :void # x and y
    attach_function :uiDrawPathCloseFigure, [DrawPath], :void
    
    #_UI_EXTERN void uiDrawStroke(uiDrawContext *c, uiDrawPath *path, uiDrawBrush *b, uiDrawStrokeParams *p);
    attach_function :uiDrawStroke, [:pointer, :pointer, :pointer, :pointer], :void

    attach_function :uiDrawMatrixSetIdentity, [DrawMatrix], :void
    attach_function :uiDrawMatrixTranslate, [DrawMatrix, :double, :double], :void #left, top
    attach_function :uiDrawMatrixScale, [
      DrawMatrix,
      :double, #xCenter
      :double, #yCenter
      :double, #x
      :double, #y
    ], :void

    attach_function :uiDrawMatrixRotate, [
      DrawMatrix,
      :double, #x
      :double, #y
      :double  #amount
    ], :void

    attach_function :uiDrawMatrixSkew, [
      DrawMatrix,
      :double, #x
      :double, #y
      :double, #xamount
      :double  #yamount
    ], :void

    attach_function :uiDrawMatrixMultiply, [
      DrawMatrix, # dest
      DrawMatrix  # src
    ], :void

    attach_function :uiDrawMatrixInvertible, [
      DrawMatrix # m
    ], :void

    attach_function :uiDrawMatrixInvert, [
      DrawMatrix # m
    ], :void

    attach_function :uiDrawMatrixTransformPoint, [
      DrawMatrix, # m
      :double,    # x
      :double     # y
    ], :void

    attach_function :uiDrawMatrixTransformSize, [
      DrawMatrix, # m
      :double,    # x
      :double     # y
    ], :void

    attach_function :uiDrawTransform, [:pointer, DrawMatrix], :void #context

    attach_function :uiDrawClip, [DrawContext, DrawPath], :void
    attach_function :uiDrawSave, [DrawContext], :void
    attach_function :uiDrawRestore, [DrawContext], :void

    attach_function :uiDrawListFontFamilies, [], FontFamilies
    attach_function :uiDrawFontFamiliesNumFamilies, [FontFamilies], :ulong_long

    attach_function :uiDrawFontFamiliesFamily, [FontFamilies, :ulong_long], :char
    attach_function :uiDrawFreeFontFamilies, [FontFamilies], :void

    # TODO example ...
    attach_function :uiDrawLoadClosestFont, [FontDescriptor], TextFont
    attach_function :uiDrawFreeTextFont, [TextFont], :void
    attach_function :uiDrawTextFontHandle, [TextFont], :ulong
    attach_function :uiDrawTextFontDescribe, [TextFont, FontDescriptor], :void
    attach_function :uiDrawTextFontGetMetrics, [TextFont, FontMetrics], :void

    attach_function :uiDrawNewTextLayout, [
      :string, # text
      TextFont, # defaultFont
      :double,  #width
    ], TextLayout

    attach_function :uiDrawFreeTextLayout, [TextLayout], :void
    attach_function :uiDrawTextLayoutSetWidth, [TextLayout, :double], :void #width
    attach_function :uiDrawTextLayoutExtents, [
      TextLayout,
      :double, #width
      :double #height
    ], :void

    attach_function :uiDrawTextLayoutSetColor, [
      TextLayout,
      :long_long, #startChar
      :long_long, #endChar
      :double, #r
      :double, #g
      :double, #b
      :double, #a
    ], :void

    attach_function :uiDrawText, [
      DrawContext,
      :double, #x
      :double, #y
      TextLayout
    ], :void
  end
end
