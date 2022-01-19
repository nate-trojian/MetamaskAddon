extends Node
class_name JavaScriptConvert

# Credit to GodotTutorial for the "protected" variable trick
# https://www.youtube.com/watch?v=NkEQyYXHyEk
var _document = JavaScript.get_interface("document") setget _protectedSet, _protectedGet
var _window = JavaScript.get_interface("window") setget _protectedSet, _protectedGet

enum Wei {
    to_Gwei
    to_Eth
   }
var _wei_convert = {
    Wei.to_Gwei: float("1e9"),
    Wei.to_Eth: float("1e18")
}

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

# Convert hex string to 64bit signed int
func hex_to_int(hex: String) -> int:
    # Save hex in temp variable
    var val = hex
    # If begins with 0x, strip it off
    if val.begins_with("0x"):
        val = val.right(2)
    # TODO - Make sure the result can even be stored in a 64bit signed int...
    # How many hex digits we are trying to handle at a time
    # hex_to_int returns a 32bit signed int, so most we can do is 28bits aka 7 chars
    var step = 7
    # Do the first step
    var num: int = str("0x" + val.substr(0, step)).hex_to_int()
    var ind = step
    # Until we surpass the string
    while ind <= len(val):
        # Get up to step characters from the string
        # Can be less characters if there aren't enough in the string
        var sub = val.substr(ind, step)
        # convert to 32bit signed int
        var hexed = ("0x"+sub).hex_to_int()
        # Shift num as many steps as we have
        num = num << (4*len(sub))
        # Add hexed to num
        num = num | hexed
        # Increment index
        ind += step
    return num

# Convert Wei int to another base
func convert_wei(wei: int, factor: int = Wei.to_Eth) -> float:
    return wei / _wei_convert[factor]
