//: [Previous](@previous)

import Foundation

// BEGIN playground_object_template
class Vehicle {
    // BEGIN playground_object_properties_basic
    var colour: String?
    var maxSpeed = 80
    // END playground_object_properties_basic
    
    // BEGIN playground_object_method_basic
    func description() -> String {
        return "A \(self.colour ?? "uncoloured") vehicle"
    }
    func travel() {
        print("Travelling at \(maxSpeed) kph")
    }
    // END playground_object_method_basic
}
// END playground_object_template

// BEGIN playground_object_instance_basic
var redVehicle = Vehicle()
redVehicle.colour = "Red"
redVehicle.maxSpeed = 90
redVehicle.travel() // prints "Traveling at 90 kph"
redVehicle.description() // = "A Red vehicle"
// END playground_object_instance_basic

// BEGIN playground_object_init_basic
class InitAndDeinitExample {
    // Designated (i.e., main) initializer
    init () {
        print("I've been created!")
    }
    // Convenience initializer, required to call the
    // designated initializer (above)
    convenience init (text: String) {
        self.init() // this is mandatory
        print("I was called with the convenience initializer!")
    }
    // Deinitializer
    deinit {
        print("I'm going away!")
    }
    
    // BEGIN playground_object_failable
    // This is a convenience initializer that can sometimes fail, returning nil
    // Note the ? after the word 'init'
    convenience init? (value: Int) {
        self.init()
        
        if value > 5 {
            // We can't initialize this object; return nil to indicate failure
            return nil
        }
        
    }
    // END playground_object_failable
}

var example : InitAndDeinitExample?

// using the designated initializer
example = InitAndDeinitExample() // prints "I've been created!"
example = nil // prints "I'm going away"

// using the convenience initializer
example = InitAndDeinitExample(text: "Hello")
// prints "I've been created!" and then
//  "I was called with the convenience initializer"
// END playground_object_init_basic

// BEGIN playground_object_failable_2
var failableExample = InitAndDeinitExample.init(value: 6) // nil
// END playground_object_failable_2

// BEGIN playground_object_properties_access
class Counter {
    var number: Int = 0
}
let myCounter = Counter()
myCounter.number = 2
// END playground_object_properties_access

// BEGIN playground_objects_properties_initialisers
class BiggerCounter {
    var number : Int
    var optionalNumber : Int?
    
    init(value: Int) {
        number = value
        // self.number now has a value
        // self.optionalNumber does not
    }
}
var anotherCounter = BiggerCounter(value:3)
anotherCounter.number // 3
// END playground_objects_properties_initialisers

// BEGIN playground_object_computed_property_1
class Rectangle {
    var width: Double = 0.0
    var height: Double = 0.0
    
    var area : Double {
        // computed getter
        get {
            return width * height
        }
        
        // computed setter
        set {
            // Assume equal dimensions (i.e., a square)
            width = sqrt(newValue)
            height = sqrt(newValue)
        }
    }
    
    // BEGIN playground_object_computed_3
    var centre : (x: Double, y: Double) {
        return (width / 2, height / 2)
    }
    // END playground_object_computed_3
}
// END playground_object_computed_property_1
// BEGIN playground_object_computed_property_2
let rect = Rectangle()
rect.width = 3.0
rect.height = 4.5
rect.area // 13.5
rect.area = 9 // width & height now both 3.0
// END playground_object_computed_property_2
// BEGIN playground_object_computed_4
rect.centre // (x: 1.5, y: 15)
// END playground_object_computed_4

// BEGIN playground_object_property_observers_1
class PropertyObserverExample {
    var number : Int = 0 {
        willSet(newNumber) {
            print("About to change to \(newNumber)")
        }
        didSet(oldNumber) {
            print("Just changed from \(oldNumber) to \(self.number)!")
        }
    }
}
// END playground_object_property_observers_1
// BEGIN playground_object_property_observers_2
var observer = PropertyObserverExample()
observer.number = 4
// prints "About to change to 4", then "Just changed from 0 to 4!"
// END playground_object_property_observers_2

// BEGIN playground_object_lazy
class SomeExpensiveClass {
    init(id : Int) {
        print("Expensive class \(id) created!")
    }
}

class LazyPropertyExample {
    var expensiveClass1 = SomeExpensiveClass(id: 1)
    // Note that we're actually constructing a class,
    // but it's labeled as lazy
    lazy var expensiveClass2 = SomeExpensiveClass(id: 2)
    
    init() {
        print("Example class created!")
    }
}

var lazyExample = LazyPropertyExample()
// prints "Expensive class 1 created", then "Example class created!"

lazyExample.expensiveClass1 // prints nothing, it's already created
lazyExample.expensiveClass2 // prints "Expensive class 2 created!"
// END playground_object_lazy

// BEGIN playground_object_inheritance
class Car : Vehicle {
    var engineType = "V8"
    
    // BEGIN playground_object_inheritence_super
    // Inherited classes can override functions
    override func description() -> String  {
        let description = super.description()
        return description + ", which is a car"
    }
    // END playground_object_inheritence_super
}
// END playground_object_inheritance

// BEGIN playground_protocol_basic
protocol Blinkable {
    // this property must be at least gettable
    var isBlinking : Bool { get }
    
    // This property must be gettable and settable
    var blinkSpeed: Double { get set }
    
    // This function must exist, but what it does is up to the implementor
    func startBlinking(blinkSpeed: Double) -> Void
}
// END playground_protocol_basic

// BEGIN playground_protocol_implementation
class TrafficLight : Blinkable {
    var isBlinking: Bool = false
    
    var blinkSpeed: Double = 0
    
    func startBlinking(blinkSpeed: Double) {
        print("I am a light and I am now blinking")
        
        isBlinking = true
        
        self.blinkSpeed = blinkSpeed
    }
}
// END playground_protocol_implementation

// BEGIN playground_protocol_types
class Lighthouse : Blinkable {
    var isBlinking: Bool = false

    var blinkSpeed : Double = 0.0

    func startBlinking(blinkSpeed : Double) {
        print("I am a lighthouse, and I am now blinking")
        isBlinking = true

        self.blinkSpeed = blinkSpeed
    }
}

var aBlinkingThing : Blinkable
// can be ANY object that has the Blinkable protocol

aBlinkingThing = TrafficLight()

aBlinkingThing.startBlinking(blinkSpeed: 4.0)
// prints "I am a light and I am now blinking"
aBlinkingThing.blinkSpeed // = 4.0

aBlinkingThing = Lighthouse()
// END playground_protocol_types

// BEGIN playground_extension_basic
extension Int {
    var double : Int {
        return self * 2
    }
    func multiplyWith(anotherNumber: Int) -> Int {
        return self * anotherNumber
    }
}
// END playground_extension_basic
// BEGIN playground_extension_int_using
2.double // 4
2.multiplyWith(anotherNumber: 5) // 10
// END playground_extension_int_using

// BEGIN playground_extension_int_blink
extension Int : Blinkable {
    var isBlinking : Bool {
        return false;
    }
    
    var blinkSpeed : Double {
        get {
            return 0.0;
        }
        set {
            // Do nothing
        }
    }
    
    func startBlinking(blinkSpeed : Double) {
        print("I am the integer \(self). I do not blink.")
    }
}
2.isBlinking // = false
2.startBlinking(blinkSpeed: 2.0)
// prints "I am the integer 2. I do not blink."
// END playground_extension_int_blink

// BEGIN playground_extension_default_blink
extension Blinkable
{
    func startBlinking(blinkSpeed: Double) {
        print("I am blinking")
    }
}
// END playground_extension_default_blink
// BEGIN playground_extension_default_another
class AnotherBlinker : Blinkable {
    var isBlinking: Bool = true
    
    var blinkSpeed: Double = 0.0
}
let anotherBlinker = AnotherBlinker()
anotherBlinker.startBlinking(blinkSpeed: 3) // print "I am blinking"
// END playground_extension_default_another

// BEGIN playground_protocol_multitype
protocol ControllableBlink : Blinkable {
    func stopBlinking()
}
// END playground_protocol_multitype

// BEGIN playground_access_public
public class AccessControl {
    // BEGIN playground_access_internal
    internal var internalProperty = 123
    // END playground_access_internal
    
    // BEGIN playground_access_privatesetter
    private(set) var privateSetProperty = 234
    // END playground_access_privatesetter
    
    // BEGIN playground_access_private
    private class PrivateAccess {
        func doStuff() -> String {
            return "Private Access is doing stuff"
        }
    }
    private let privateClass = PrivateAccess()
    
    func doAThing()
    {
        print(self.privateClass.doStuff())
    }
    // END playground_access_private
    
    // BEGIN playground_access_fileprivate
    fileprivate class FileAccess {
        func doStuff() -> String {
            return "File private access is doing stuff"
        }
    }
    fileprivate let fileClass = FileAccess()
    func doAFilePrivateThing()
    {
        print(self.fileClass.doStuff())
    }
    // END playground_access_fileprivate
}
// END playground_access_public

// BEGIN playground_access_private_use
let accessControl = AccessControl()
accessControl.doAThing() // prints "Private Access is doing stuff"
// accessControl.privateClass accessing this is an error
// it can't be accessed outside of the AccessControl definition
// END playground_access_private_use

// BEGIN playground_access_fileprivate_use
accessControl.doAFilePrivateThing()
accessControl.fileClass.doStuff()
// END playground_access_fileprivate_use

// BEGIN playground_access_privatesetter_use
accessControl.privateSetProperty // 234
// accessControl.privateSetProperty = 4
// trying the above is an error!
// END playground_access_privatesetter_use

// BEGIN playground_access_final_1
final class FinalClass {}

// class FinalSubClass : FinalClass {}
// error: inheritance from a final class 'FinalClass'
// END playground_access_final_1

// BEGIN playground_access_final_2
class PartiallyFinalClass {
    final func doStuff(){
        print("doing stuff")
    }
}
class PartiallyFinalSubClass : PartiallyFinalClass {
    // override func doStuff() { print("Doing different stuff") }
    // error: instance method overrides a 'final' instance method
}
// END playground_access_final_2

// BEGIN playground_operator_plus
extension Int {
    static func + (left: Int, right: Int) -> Int {
        return left * right
    }
}
4 + 2 // 8
// END playground_operator_plus

// BEGIN playground_operator_vector
class Vector2D {
    var x : Float = 0.0
    var y : Float = 0.0

    init (x : Float, y: Float) {
        self.x = x
        self.y = y
    }
}
// END playground_operator_vector
// BEGIN playground_operator_vector_plus
func +(left : Vector2D, right: Vector2D) -> Vector2D {
    let result = Vector2D(x: left.x + right.x, y: left.y + right.y)
    
    return result
}
// END playground_operator_vector_plus
// BEGIN playground_operator_vector_plus_using
let first = Vector2D(x: 2, y: 2)
let second = Vector2D(x: 4, y: 1)

let result = first + second
// (x:6, y:3)
// END playground_operator_vector_plus_using

// BEGIN playground_operator_vector_dot_define
infix operator •
// END playground_operator_vector_dot_define
// BEGIN playground_operator_vector_dot
func •(left : Vector2D, right: Vector2D) -> Vector2D {
    let result = Vector2D(x: left.x * right.x, y: left.y * right.y)
    
    return result
}
// END playground_operator_vector_dot
// BEGIN playground_operator_vector_dot_using
first • second //(x: 6, y: 2)
// END playground_operator_vector_dot_using

// BEGIN playground_subscript_define
// Extend the unsigned 8-bit integer type
extension UInt8 {
    // Allow subscripting this type using UInt8s;
    subscript(bit: UInt8) -> UInt8 {
        // This is run when you do things like "value[x]"
        get {
            return (self >> bit & 0x07) & UInt8(1)
        }
        
        // This is run when you do things like "value[x] = y"
        set {
            let cleanBit = bit & 0x07
            let mask : UInt8 = 0xFF ^ (1 << cleanBit)
            let shiftedBit = (newValue & 1) << cleanBit
            self = self & mask | shiftedBit
        }
    }
}
// END playground_subscript_define

// BEGIN playground_subscript_use
var byte : UInt8 = 212

byte[0] // 0
byte[2] // 1
byte[5] // 0
byte[6] // 1

// Change the last bit
byte[7] = 0

// The number is now changed!
byte // 84
// END playground_subscript_use

// BEGIN playground_generic_tree
class Tree <T> {
    // 'T' can now be used as a type inside this class
    
    // 'value' is of type T
    var value : T
    
    // 'children' is an array of Tree objects that have
    // the same type as this one
    private (set) var children : [Tree <T>] = []
    
    // We can initialize this object with a value of type T
    init(value : T) {
        self.value = value
    }
    
    // And we can add a child node to our list of children
    func addChild(value : T) -> Tree <T> {
        let newChild = Tree<T>(value: value)
        children.append(newChild)
        return newChild
    }
}
// END playground_generic_tree

// BEGIN playground_generic_tree_using
// Tree of integers
let integerTree = Tree<Int>(value: 5)

// Can add children that contain Ints
integerTree.addChild(value: 10)
integerTree.addChild(value: 5)

// Tree of strings
let stringTree = Tree<String>(value: "Hello")

stringTree.addChild(value: "Yes")
stringTree.addChild(value: "Internets")
// END playground_generic_tree_using

//: [Next](@next)
