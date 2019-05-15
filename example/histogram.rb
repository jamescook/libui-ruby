# This example attempts to follow the code in https://github.com/andlabs/libui/blob/a038923060f4183ff6d62faa94d2c56e49f52831/examples/histogram/main.c

#CG_CONTEXT_SHOW_BACKTRACE=1 bundle exec ruby example/histogram.rb
require "libui"

X_OFF_LEFT = 20
Y_OFF_TOP  = 20
X_OFF_RIGHT = 20
Y_OFF_BOTTOM = 20
POINT_RADIUS = 5

options   = LibUI::Ext::InitOptions.new
init      = LibUI::Ext.uiInit(options)
handler   = LibUI::Ext::AreaHandler.new
histogram = LibUI::Ext.uiNewArea(handler)
brush     = LibUI::Ext::DrawBrush.new
color_button = LibUI::Ext.uiNewColorButton
blue = 0x1E90FF
datapoints = []

def graph_size(area_width, area_height)
	graph_width = area_width - X_OFF_LEFT - X_OFF_RIGHT
	graph_height = area_height - Y_OFF_TOP - Y_OFF_BOTTOM
  return [graph_width, graph_height]
end

matrix = LibUI::Ext::DrawMatrix.new

def point_locations(datapoints, width, height)
  xincr = width / 9.0 # 10 - 1 to make the last point be at the end
  yincr = height / 100.0

  data = []
  datapoints.each_with_index do |dp, i|
    val = 100 - LibUI::Ext.uiSpinboxValue(dp)
    data << [xincr * i, yincr * val]
    i = i + 1
  end

  data
end

def construct_graph(datapoints, width, height, should_extend)
  locations = point_locations(datapoints, width, height)
  path = LibUI::Ext.uiDrawNewPath(LibUI::Ext::FILL_MODES[:winding])
  first_location = locations[0] # x and y
	LibUI::Ext.uiDrawPathNewFigure(path, first_location[0], first_location[1])
  locations.each do |loc|
		LibUI::Ext.uiDrawPathLineTo(path, loc[0], loc[1])
  end

  if should_extend
		LibUI::Ext.uiDrawPathLineTo(path, width, height)
		LibUI::Ext.uiDrawPathLineTo(path, 0, height)
    LibUI::Ext.uiDrawPathCloseFigure(path)
  end

	LibUI::Ext.uiDrawPathEnd(path)
  
  path
end

handler_draw_event = lambda do |area_handler, area, area_draw_params|
	path = LibUI::Ext.uiDrawNewPath(LibUI::Ext::FILL_MODES[:winding])
  LibUI::Ext.uiDrawPathAddRectangle(path, 0, 0, area_draw_params[:width], area_draw_params[:height])
	LibUI::Ext.uiDrawPathEnd(path)
	set_solid_brush(brush, 0xFFFFFF, 1.0)  #white
	LibUI::Ext.uiDrawFill(area_draw_params[:draw_context], path, brush.to_ptr)
	LibUI::Ext.uiDrawFreePath(path)
  dsp = LibUI::Ext::DrawStrokeParams.new
  dsp[:cap] = LibUI::Ext::LINE_CAPS[:flat]
	dsp[:join] = LibUI::Ext::LINE_JOINS[:miter]
	dsp[:thickness] = 2
	dsp[:miter_limit] = LibUI::Ext::DEFAULT_MITER_LIMIT # 10

  # draw axes
	set_solid_brush(brush, 0x000000, 1.0) # black
	graph_width, graph_height = *graph_size(area_draw_params[:width], area_draw_params[:height])

	path = LibUI::Ext.uiDrawNewPath(LibUI::Ext::FILL_MODES[:winding])
  LibUI::Ext.uiDrawPathNewFigure(path, X_OFF_LEFT, Y_OFF_TOP)
  LibUI::Ext.uiDrawPathLineTo(path, X_OFF_LEFT, Y_OFF_TOP + graph_height)
  LibUI::Ext.uiDrawPathEnd(path)
	LibUI::Ext.uiDrawStroke(area_draw_params[:draw_context], path, brush, dsp)
  LibUI::Ext.uiDrawFreePath(path)

	# now transform the coordinate space so (0, 0) is the top-left corner of the graph
  LibUI::Ext.uiDrawMatrixSetIdentity(matrix)
	LibUI::Ext.uiDrawMatrixTranslate(matrix, X_OFF_LEFT, Y_OFF_TOP)
  LibUI::Ext.uiDrawTransform(area_draw_params[:draw_context], matrix)

  # now get the color for the graph itself and set up the brush
  #	uiColorButtonColor(colorButton, &graphR, &graphG, &graphB, &graphA)
  graph_r = FFI::MemoryPointer.new(:double)
  graph_g = FFI::MemoryPointer.new(:double)
  graph_b = FFI::MemoryPointer.new(:double)
  graph_a = FFI::MemoryPointer.new(:double)

	LibUI::Ext.uiColorButtonColor(color_button, graph_r, graph_g, graph_b, graph_a)
	brush[:type] = LibUI::Ext::BRUSH_TYPES[:solid]
	brush[:red]   = graph_r.read_double
	brush[:green] = graph_g.read_double
	brush[:blue]  = graph_b.read_double

	# now create the fill for the graph below the graph line
  path = construct_graph(datapoints, graph_width, graph_height, true)
	brush[:alpha] = graph_a.read_double / 2.0
  LibUI::Ext.uiDrawFill(area_draw_params[:draw_context], path, brush)
  LibUI::Ext.uiDrawFreePath(path)

	# now draw the histogram line
  path = construct_graph(datapoints, graph_width, graph_height, false)
	brush[:alpha] = graph_a.read_double
	LibUI::Ext.uiDrawStroke(area_draw_params[:draw_context], path, brush, dsp)
	LibUI::Ext.uiDrawFreePath(path)
end

handler[:draw_event] = handler_draw_event
handler[:mouse_event] = Proc.new do |*args|
  #puts "mouse moved: #{args.inspect}"
end
handler[:mouse_crossed] = Proc.new{}
handler[:drag_broken] = Proc.new{}
handler[:key_event] = Proc.new{}

if init != nil
  LibUI::Ext.uiFreeInitError(init)
end

hbox = LibUI::Ext.uiNewHorizontalBox
LibUI::Ext.uiBoxSetPadded(hbox, 1)

vbox = LibUI::Ext.uiNewVerticalBox
LibUI::Ext.uiBoxSetPadded(vbox, 1)
LibUI::Ext.uiBoxAppend(hbox, vbox, 0)
LibUI::Ext.uiBoxAppend(hbox, histogram, 1);

spinbox_changed = Proc.new do |ptr|
  LibUI::Ext.uiAreaQueueRedrawAll(histogram)
end

10.times do |i|
  datapoints << LibUI::Ext.uiNewSpinbox(0, 100)
  LibUI::Ext.uiSpinboxSetValue(datapoints[i], Random.new.rand(90))
  LibUI::Ext.uiSpinboxOnChanged(datapoints[i], spinbox_changed, nil)
  LibUI::Ext.uiBoxAppend(vbox, datapoints[i], 0)
end

def set_solid_brush(brush, color, alpha)
  brush[:type] = LibUI::Ext::BRUSH_TYPES[:solid]
  brush[:red]   = ((color >> 16) & 0xFF) / 255.0
  brush[:green] = ((color >> 8) & 0xFF) / 255.0
  brush[:blue] = (color & 0xFF) / 255.0
  brush[:alpha] = alpha
  brush
end

set_solid_brush(brush, blue, 1.0)
LibUI::Ext.uiColorButtonSetColor(color_button, brush[:red], brush[:green], brush[:blue], brush[:alpha])

color_changed = Proc.new do |ptr|
	LibUI::Ext.uiAreaQueueRedrawAll(histogram)
end

LibUI::Ext.uiColorButtonOnChanged(color_button, color_changed, nil)
LibUI::Ext.uiBoxAppend(vbox, color_button, 0)

MAIN_WINDOW = LibUI::Ext.uiNewWindow("histogram example", 640, 480, 1)
LibUI::Ext.uiWindowSetMargined(MAIN_WINDOW, 1)
LibUI::Ext.uiWindowSetChild(MAIN_WINDOW, hbox)

should_quit = Proc.new do |ptr|
  LibUI::Ext.uiControlDestroy(MAIN_WINDOW)
  LibUI::Ext.uiQuit
  0
end

LibUI::Ext.uiWindowOnClosing(MAIN_WINDOW,should_quit, nil)
LibUI::Ext.uiOnShouldQuit(should_quit, nil)
LibUI::Ext.uiControlShow(MAIN_WINDOW)

LibUI::Ext.uiMain
LibUI::Ext.uiQuit
