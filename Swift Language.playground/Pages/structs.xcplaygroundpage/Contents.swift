//: [Previous](@previous)

import Foundation

// BEGIN playground_struct_point
struct Point {
    var x: Int
    var y: Int
}
// END playground_struct_point

// BEGIN playground_struct_point_using
let p = Point(x: 2, y: 3)
// END playground_struct_point_using

// BEGIN playground_struct_number
struct NumberStruct {
    var number : Int
}
class NumberClass {
    var number : Int
    
    init(_ number: Int) {
        self.number = number
    }
}
// END playground_struct_number

// BEGIN playground_struct_number_using
var numberClass1 = NumberClass(3)
var numberClass2 = numberClass1
numberClass1.number // 3
numberClass2.number // 3

var numberStruct1 = NumberStruct(number: 3)
var numberStruct2 = numberStruct1
numberStruct1.number // 3
numberStruct2.number // 3
// END playground_struct_number_using

// BEGIN playground_struct_number_changing
numberStruct2.number = 4
numberStruct1.number // 3

numberClass2.number = 4
numberClass1.number // 4
// END playground_struct_number_changing

//: [Next](@next)
