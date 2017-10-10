// BEGIN playground_comments
// this is a single line comment

/* this is a multiple
 line comment
 */

/* this is a comment
 
 /* this is a comment inside another comment */
 
 still a comment! */
// END playground_comments

//: Playground - noun: a place where people can play

import UIKit

// BEGIN playground_var_initial
var str = "Hello, playground"
// END playground_var_initial

// BEGIN playground_var_example
var myVariable = 123
let myConstantVariable = 123
// END playground_var_example

// BEGIN playground_var_mutating
myVariable += 5
str = "Hello there"
// this is an error
// myConstantVariable = 2
// END playground_var_mutating

// BEGIN playground_explicit_initial
let explicitInt : Int = 5
// END playground_explicit_initial
// BEGIN playground_explicit_double
var explicitDouble : Double = 5
explicitDouble + 0.3
// END playground_explicit_double

// BEGIN playground_empty_vars
var someVariable : Int
// this is an error
// someVariable += 2

// this works
someVariable = 0
someVariable += 2
// END playground_empty_vars

// BEGIN playground_semicolon
var exampleInteger = 5; print(exampleInteger)
// END playground_semicolon
// BEGIN playground_multiline_code
var anotherExampleInt
    = 7
// END playground_multiline_code

// BEGIN playground_arthimetic_operators
1 + 7 // 8
6 - 4 // 2
8 / 2 // 4
3 * 5 // 15
// END playground_arthimetic_operators

// BEGIN playground_equality_operators
2 == 2        // true
2 != 2        // false
"yes" == "no" // false
"yes" != "no" // true
// END playground_equality_operators

// BEGIN playground_comparision_operators
5 < 7  // true
1 > 4  // false
2 <= 1 // false
3 >= 3 // true
// END playground_comparision_operators

// BEGIN playground_dot_operator
true.description  // "true"
4.advanced(by: 3) // 7
// END playground_dot_operator

//: Arrays
// BEGIN playground_collection_array_init
let intArray = [1,2,3,4,5]
// END playground_collection_array_init

// BEGIN playground_collection_array_subscript
intArray[2] // 3
// END playground_collection_array_subscript

// BEGIN playground_collection_array_explicit
let explicitIntArry : [Int] = [1,2,3,4,5]
// END playground_collection_array_explicit

// BEGIN playground_collection_array_bounds
// intArray[-1] // this will error if we try and run it
// END playground_collection_array_bounds

// BEGIN playground_collection_array_mutable
var mutableArray = [1,2,3,4,5]
// END playground_collection_array_mutable

// BEGIN playground_collection_array_modify
// can append elements to the end of the array
mutableArray.append(6) // [1, 2, 3, 4, 5, 6]
// can remove elements at a specific index
mutableArray.remove(at: 2) // returns 3, array now holds [1, 2, 4, 5, 6]
// can replace elements at a specific index
mutableArray[0] = 3 // returns 3, array now holds [3, 2, 4, 5, 6]
// can insert elements at a specific index
mutableArray.insert(3, at: 2) // array now holds [3, 2, 3, 4, 5, 6]
// END playground_collection_array_modify

// BEGIN playground_collection_array_empty
var emptyArray = [Int]()
// this will create an empty Int array
emptyArray.append(0) // [0]
// END playground_collection_array_empty

// BEGIN playground_collection_array_useful
// returns the number of elements in the array
intArray.count // 5
// END playground_collection_array_useful

// BEGIN playground_collection_dict_init
var crew = ["Captain": "Benjamin Sisko",
            "First Officer": "Kira Nerys",
            "Constable": "Odo"]
// END playground_collection_dict_init

// BEGIN playground_collection_dict_keys
crew["Captain"] // "Benjamin Sisko"
// END playground_collection_dict_keys

// BEGIN playground_collection_dict_add
crew["Doctor"] = "Julian Bashir"
crew["Security Officer"] = "Michael Eddington"
// END playground_collection_dict_add

// BEGIN playground_collection_dict_remove
crew.removeValue(forKey: "Security Officer")
// END playground_collection_dict_remove

// BEGIN playground_collection_dict_nil
crew["Science Officer"] = "Jadzia Dax"
crew["Science Officer"] = nil
crew["Science Officer"] // nil
// END playground_collection_dict_nil

// BEGIN playground_collection_dict_array
let arrayDictionary = [0:1,
                       1:2,
                       2:3,
                       3:4,
                       4:5]
arrayDictionary[0] // 1
// END playground_collection_dict_array

// BEGIN playground_collection_tuple_basic
let fileNotFound = (404,"File Not Found")
// END playground_collection_tuple_basic
// BEGIN playground_collection_tuple_index
fileNotFound.0 // 404
// END playground_collection_tuple_index
// BEGIN playground_collection_tuple_labelled
let serverError = (code:500, message:"Internal Server Error")

serverError.message // "Internal Server Error"
// END playground_collection_tuple_labelled


// BEGIN playground_if_basic
if 1+2 == 3 {
    print("The maths checks out")
}
// this will print "the maths checks out" which is a relief
// END playground_if_basic

// BEGIN playgrounds_if_advanced
let ifVariable = 5

if ifVariable == 1 {
    print("it is one")
}
else if ifVariable <= 3 {
    print("it is less than or equal to three")
}
else if ifVariable == 4 {
    print("it is four")
}
else {
    print("it is something else")
}
// this will print "it is something else"
// END playgrounds_if_advanced

// BEGIN playground_loops_for
let loopArray = [1,2,3,4,5,6,7,8,9,10]
var sum = 0
for number in loopArray {
    sum += number
}
sum // 55
// END playground_loops_for

// BEGIN playground_loop_for_range
// resetting our counter to 0
sum = 0
for number in 1 ..< 10 {
    sum += number
}
sum // 45
// END playground_loop_for_range
// BEGIN playground_loop_for_fullrange
// resetting our counter to 0
sum = 0
for number in 1 ... 10 {
    sum += number
}
sum // 55
// END playground_loop_for_fullrange
// BEGIN playground_loop_for_stride1
var strideSum : Double = 0
for number in stride(from: 0, to: 1, by: 0.1) {
    strideSum += number
}
strideSum // 4.5
// END playground_loop_for_stride1
// BEGIN playground_loop_for_stride2
// resetting out counter
strideSum = 0
for number in stride(from: 0, through: 1, by: 0.1) {
    strideSum += number
}
strideSum // 5.5
// END playground_loop_for_stride2

// BEGIN playground_loop_while_basic
var countDown = 5
while countDown > 0 {
    countDown -= 1
}
countDown // 0
// END playground_loop_while_basic
// BEGIN playground_loop_while_repeat
var countUp = 0
repeat {
    countUp += 1
} while countUp < 5
countUp // 5
// END playground_loop_while_repeat


// BEGIN playground_switch_basic
let integerSwitch = 3
switch integerSwitch {
case 0:
    print("It's 0")
case 1:
    print("It's 1")
case 2:
    print("It's 2")
default:
    print("It's something else")
} // Prints "It's something else"
// END playground_switch_basic

// BEGIN playground_switch_range
var someNumber = 15
switch someNumber {
case 0...10:
    print("Number is between 0 and 10")
case 11...20:
    print("Number is between 11 and 20")
case 21:
    print("Numer is 21!")
default:
    print("Number is something else")
}
// Prints "Number is between 11 and 20"
// END playground_switch_range

// BEGIN playground_switch_fallthrough
let fallthroughSwitch = 10
switch fallthroughSwitch {
case 0..<20:
    print("Number is between 0 and 20")
    fallthrough
case 0..<30:
    print("Number is between 0 and 30")
default:
    print("Number is something else")
}
// Prints "Number is between 0 and 20" and then "Number is between 0 and 30"
// END playground_switch_fallthrough

// BEGIN playground_switch_strings
let greeting = "Hello"
switch greeting {
case "Hello":
    print("Oh hello there.")
case "Goodbye":
    print("Sorry to see you leave.")
default:
    print("Huh?")
}
// Prints "Oh hello there."
// END playground_switch_strings

// BEGIN playground_switch_tuple
let switchingTuple = ("Yes", 123)
switch switchingTuple {
case ("Yes", 123):
    print("Tuple contains 'Yes' and '123'")
case ("Yes", _):
    print("Tuple contains 'Yes' and something else")
case (let string, _):
    print("Tuple contains the string '\(string)' and something else")
}
// Prints "Tuple contains 'Yes' and '123'"
// END playground_switch_tuple

// BEGIN playground_type_intExample
let firstInt = 3
let secondInt = 5
firstInt + secondInt // 8
// END playground_type_intExample
// BEGIN playground_type_double_example
15.2 + 3 // 18.2
// END playground_type_double_example


// BEGIN playground_strings_empty
let emptyString = ""
// END playground_strings_empty

// BEGIN playground_strings_empty_copy
let anotherEmptyString = String()
// END playground_strings_empty_copy

// BEGIN playground_strings_empty_check
emptyString.isEmpty // true
// END playground_strings_empty_check

// BEGIN playground_strings_composition
var composingString = "Hello"
composingString += " world" // "Hello world"
// END playground_strings_composition
// BEGIN playground_strings_unicode
composingString += " 💯" // "Hello world 💯"
// END playground_strings_unicode

// BEGIN playground_strings_characters
for character in "hello"
{
    print(character)
}
// "h"
// "e"
// "l"
// "l"
// "o"
// END playground_strings_characters

// BEGIN playgrounds_string_count
composingString.count // 13
// END playgrounds_string_count

// BEGIN playground_strings_compare
let string1 : String = "Hello"
let string2 : String = "Hel" + "lo"
if string1 == string2 {
    print("The strings are equal")
}
// END playground_strings_compare

// BEGIN playground_strings_compare_unicode
let café = "Café"
let cafe = "Cafe\u{301}"
if cafe == café {
    print("The strings are equal")
}
// END playground_strings_compare_unicode

// BEGIN playground_strings_case
"Café".uppercased() // "CAFÉ"
"Café".lowercased() // café
// END playground_strings_case

// BEGIN playground_string_nfix
if "Hello".hasPrefix("H") {
    print("String begins with an H")
}
if "Hello".hasSuffix("llo") {
    print("String ends in llo")
}
// END playground_string_nfix

// BEGIN playground_string_interpolation
let name = "Fred"
let age = 21
let line = "My name is \(name) and I am \(age) years old."
// "My name is Fred and I am 21 years old."
// END playground_string_interpolation

// BEGIN playground_conversion_basic
let three = Int("3") // 3
// END playground_conversion_basic

// BEGIN playground_conversion_precision
let almostMeaningOfLife = String(Int(41.999999)) // "41"
// END playground_conversion_precision

// BEGIN playground_conversion_optional
let number = Int("lorem ipsum") // nil
// END playground_conversion_optional

// BEGIN playground_optional_initial
// Optional integer, allowed to be nil
var anOptionalInteger : Int? = nil
anOptionalInteger = 42
// END playground_optional_initial

// BEGIN playground_optional_non
// Nonoptional (regular), NOT allowed to be nil
var aNonOptionalInteger = 42
//aNonOptionalInteger = nil
// ERROR: only optional values can be nil
// END playground_optional_non

// BEGIN playground_optional_check
if anOptionalInteger != nil {
    print("It has a value!")
}
else {
    print("It has no value!")
}
// END playground_optional_check

// BEGIN playground_optional_forced_unwrap
// Optional types must be unwrapped using !
anOptionalInteger = 2
1 + anOptionalInteger! // 3
anOptionalInteger = nil
// 1 + anOptionalInteger!
// CRASH: anOptionalInteger = nil, can't use nil data
// END playground_optional_forced_unwrap

// BEGIN playground_optional_implicit
var implicitlyUnwrappedOptionalInteger : Int!
implicitlyUnwrappedOptionalInteger = 1
1 + implicitlyUnwrappedOptionalInteger // 2
// END playground_optional_implicit

// BEGIN playground_optional_iflet
var conditionalString : String? = "a string"
if let theString = conditionalString {
    print("The string is '\(theString)'")
}
else {
    print("The string is nil")
}
// Prints "The string is 'a string'"
// END playground_optional_iflet

// BEGIN playground_optional_chaining_1
var optionalArray : [Int]? = [1,2,3,4]
var count = optionalArray?.count
// count is an optional Int with 4
// END playground_optional_chaining_1

// BEGIN playground_optional_chaining_2
optionalArray = nil
count = optionalArray?.count
// count is nil
// END playground_optional_chaining_2

// BEGIN playground_optional_chaining_3
let optionalDict : [String : [Int]]? = ["array":[1,2,3,4]]
count = optionalDict?["array"]?.count
// count is an optional Int with 4
// END playground_optional_chaining_3

// BEGIN playground_optional_coalescing_1
var values = ["name":"fred"]
var personsAge = "unspecified"

if let unwrappedValue = values["age"] {
    personsAge = unwrappedValue
}

print("They are \(personsAge) years old")
// prints "They are unspecified years old"
// END playground_optional_coalescing_1

// BEGIN playground_optional_coalescing_2
personsAge = values["age"] ?? "unspecified"
print("They are \(personsAge) years old")
// prints "They are unspecified years old"
// END playground_optional_coalescing_2

// BEGIN playground_optional_coalescing_3
personsAge = values["age", default: "unspecified"]
print("They are \(personsAge) years old")
// prints "They are unspecified years old"
// END playground_optional_coalescing_3

// BEGIN playground_typecast_any
let person : [String:Any] = ["name":"Jane","Age":26,"Wears glasses":true]
// END playground_typecast_any

// BEGIN playground_typecast_check
let possibleString = person["name"]
if possibleString is String {
    print("\(possibleString!) is a string!")
} // prints "Jane is a string!"
// END playground_typecast_check

// BEGIN playground_typecaste_as1
if let name = person["name"] {
    var maybeString = name as? String
    // maybeString is an optional String containing "Jane"
    
    var maybeInt = name as? Int
    // maybeInt is an optional Int containing nil
}
// END playground_typecaste_as1

// BEGIN playground_typecaste_as2
if let name = person["name"] {
    var maybeString = name as! String
    // maybeString is a String containing "Jane"
}
// END playground_typecaste_as2

// BEGIN playground_typcast_any_var
var anything : Any = "hello"
anything = 3
anything = false
anything = [1,2,3,4]
// END playground_typcast_any_var

// BEGIN playground_set_init
var setOfStrings = Set<String>()
// END playground_set_init

// BEGIN playground_set_array
var fruitSet : Set = ["apple","orange","orange","banana"]
// END playground_set_array

// BEGIN playground_set_count
fruitSet.count // 3
// END playground_set_count

// BEGIN playground_set_modify
if fruitSet.isEmpty {
    print("My set is empty!")
}

// Add a new item to the set
fruitSet.insert("pear")
// Remove an item from the set
fruitSet.remove("apple")
// fruitSet now contains {"banana", "pear", "orange"}
// END playground_set_modify

// BEGIN playground_set_index
// getting the index of "pear"
let index = fruitSet.index(of: "pear")
// index is now an optional Set.Index type
fruitSet[index!] // "pear"
// END playground_set_index

// BEGIN playground_set_loop
for fruit in fruitSet {
    let fruitPlural = fruit + "s"
    print("You know what's tasty? \(fruitPlural.uppercased()).")
}
// END playground_set_loop

// BEGIN playground_enum_basic
// enumeration of top secret future iPads that definitely
// will never exist
enum FutureiPad {
    case iPadSuperPro
    case iPadTotallyPro
    case iPadLudicrous
}
// END playground_enum_basic

// BEGIN playground_enum_var
var nextiPad = FutureiPad.iPadTotallyPro
// END playground_enum_var
// BEGIN playground_enum_var_mutable
nextiPad = .iPadSuperPro
// END playground_enum_var_mutable

// BEGIN playground_enum_switch
switch nextiPad {
case .iPadSuperPro:
    print("Too big!")
case .iPadTotallyPro:
    print("Too small!")
case .iPadLudicrous:
    print("Just right!")
} // prints "Too big!"
// END playground_enum_switch

// BEGIN playground_enum_associated_1
enum BasicWeapon {
    case laser
    case missiles
}
// END playground_enum_associated_1

// BEGIN playground_enum_associated_2
enum AdvancedWeapon {
    case laser(powerLevel: Int)
    case missiles(range: Int)
}
// END playground_enum_associated_2

// BEGIN playground_enum_associated_var
let spaceLaser = AdvancedWeapon.laser(powerLevel: 5)
// END playground_enum_associated_var

// BEGIN playground_enum_associated_switch
switch spaceLaser {
case .laser(powerLevel: 0...10 ):
    print("It's a laser with power from 0 to 10!")
case .laser:
    print("It's a laser!")
case .missiles(let range):
    print("It's a missile with range \(range)!")
}
// Prints "It's a laser with power from 0 to 10!"
// END playground_enum_associated_switch

// BEGIN playground_enum_raw
enum Response : String {
    case hello = "Hi"
    case goodbye = "See you next time"
    case thankYou = "No worries"
}
// END playground_enum_raw

// BEGIN playground_enum_raw_val
let hello = Response.hello
hello.rawValue // "Hi"
// END playground_enum_raw_val

// BEGIN playground_enum_raw_create
Response(rawValue: "Hi") // is an optional Response with .hello inside
// END playground_enum_raw_create

// BEGIN playground_enum_raw_implicit
enum Nucleobase : String {
    case cytosine, guanine, adenine, thymine
}
Nucleobase.adenine.rawValue // "adenine"

// can also give an initial value
enum Element : Int {
    case hydrogen = 1, helium, lithium, beryl­lium, boron, carbon, nitrogen
}
Element.lithium.rawValue // 3
// END playground_enum_raw_implicit
