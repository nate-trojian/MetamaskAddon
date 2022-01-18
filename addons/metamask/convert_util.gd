extends Node
class_name JavaScriptConvert

# Credit to GodotTutorial for the "protected" variable trick
# https://www.youtube.com/watch?v=NkEQyYXHyEk
var _document = JavaScript.get_interface("document") setget _protectedSet, _protectedGet
var _window = JavaScript.get_interface("window") setget _protectedSet, _protectedGet

func _protectedSet(_val):
    push_error("cannot access protected variable")

func _protectedGet():
    push_error("cannot access protected variable")

func _ready():
    _convert_util_script()

func _convert_util_script():
    var script_txt = "function convert_util(obj) { return Object.entries(obj); }"
    var script_block = _document.createElement('script')
    script_block.id = "convertUtil"
    var text_block = _document.createTextNode(script_txt)
    script_block.appendChild(text_block)
    _document.head.appendChild(script_block)

func _convert_arr(arr):
    var ret = []
    var n = arr.length
    for i in n:
        ret.append(to_GDScript(arr[i]))
    return ret

func _convert_obj(obj):
    # Get the javascript keys
    var ret = {}
    # Returns Array of [key, val] pairs
    var entries = _window.convert_util(obj)
    var n = entries.length
    for i in n:
        var key_val = entries[i]
        ret[key_val[0]] = to_GDScript(key_val[1])
    return ret

func to_GDScript(val):
    match typeof(val):
        # JavaScriptObject is TYPE_OBJECT
        TYPE_OBJECT:
            # Use the constructor name to split between array and object
            if val.constructor.name == 'Array':
                return _convert_arr(val)
            elif val.constructor.name == 'Object':
                return _convert_obj(val)
            # Only other case is a function, and we should keep that a JavaScriptObject...
            return val
        _:
            # Primitives are already converted to GDscript types
            return val

# Convert from GDScript Array to JavaScript Array
func arr_to_js(arr: Array) -> JavaScriptObject:
    var val = JavaScript.create_object('Array', len(arr))
    for i in range(len(arr)):
        val[i] = arr[i]
    return val

# Convert from GDScript Dictionary to JavaScript Dictionary
func dict_to_js(dict: Dictionary) -> JavaScriptObject:
    var val = JavaScript.create_object('Object')
    for key in dict:
        val[key] = dict[key]
    return val
