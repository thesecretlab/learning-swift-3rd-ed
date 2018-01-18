//: [Previous](@previous)

import Foundation

// BEGIN playground_func_basic
func sayHello() {
    print("Hello")
}
sayHello() // prints "Hello"
// END playground_func_basic

// BEGIN playground_func_return
func usefulNumber() -> Int {
    return 123
}

let anUsefulNumber = usefulNumber() // 123
// END playground_func_return

// BEGIN playground_func_params
func addNumbers(firstValue: Int, secondValue: Int) -> Int {
    return firstValue + secondValue
}
let result = addNumbers(firstValue: 1, secondValue: 2) // 3
// END playground_func_params

// BEGIN playground_func_multireturn
func processNumbers(firstValue: Int, secondValue: Int) -> (doubled: Int, quadrupled: Int)
{
    return (firstValue * 2, secondValue * 4)
}
// END playground_func_multireturn

// BEGIN playground_func_multireturn_access
// Accessing by number:
processNumbers(firstValue: 2, secondValue: 4).1 // = 16
// Same thing but with names:
processNumbers(firstValue: 2, secondValue: 4).quadrupled // = 16
// END playground_func_multireturn_access

// BEGIN playground_func_labels_basic
func subtractNumbers(_ num1 : Int, _ num2 : Int) -> Int {
    return num1 - num2
}
subtractNumbers(5, 3) // 2
// END playground_func_labels_basic

// BEGIN playground_func_labels_advanced
func add(firstNumber num1 : Int, toSecondNumber num2: Int) -> Int {
    return num1 + num2
}
add(firstNumber: 2, toSecondNumber: 3) // 5
// END playground_func_labels_advanced

// BEGIN playground_func_params_default
func multiplyNumbers2(firstNumber: Int, multiplier: Int = 2) -> Int {
    return firstNumber * multiplier;
}
// Parameters with default values can be omitted
multiplyNumbers2(firstNumber: 2) // 4
// END playground_func_params_default

// BEGIN playground_func_variadic
func sumNumbers(numbers: Int...) -> Int {
    // in this function, 'numbers' is an array of Ints
    var total = 0
    for number in numbers {
        total += number
    }
    return total
}
sumNumbers(numbers: 1,2,3,4,5,6,7,8,9,10) // 55
// END playground_func_variadic

// BEGIN playground_func_inout
func swapValues(firstValue: inout Int, secondValue: inout Int) {
    (firstValue, secondValue) = (secondValue, firstValue)
}
var swap1 = 2
var swap2 = 3
swapValues(firstValue: &swap1, secondValue: &swap2)
swap1 // 3
swap2 // 2
// END playground_func_inout

// BEGIN playground_func_variables
var numbersFunc: (Int, Int) -> Int
// numbersFunc can now store any function that takes two ints and returns an int
// Using the 'addNumbers' function from before
numbersFunc = addNumbers
numbersFunc(2, 3) // 5
// END playground_func_variables

// BEGIN playground_func_combine_func_1
func timesThree(number: Int) -> Int {
    return number * 3
}
func doSomethingTo(aNumber: Int, thingToDo: (Int)->Int) -> Int {
    // we've received some function as a parameter, which we refer to as
    // 'thingToDo' inside this function.
    // call the function 'thingToDo' using 'aNumber', and return the result
    return thingToDo(aNumber)
}
// Give the 'timesThree' function to use as 'thingToDo'
doSomethingTo(aNumber: 4, thingToDo: timesThree) // 12
// END playground_func_combine_func_1

// BEGIN playground_func_combine_func_2
// This function takes an Int as a parameter. It returns a new function that
// takes an Int parameter and return an Int.
func createAdder(numberToAdd: Int) -> (Int) -> Int {
    func adder(number: Int) -> Int {
        return number + numberToAdd
    }
    return adder
    
}
var addTwo = createAdder(numberToAdd: 2)
// addTwo is now a function that can be called
addTwo(2) // 4
// END playground_func_combine_func_2

// BEGIN playground_closure_sort
let jumbledArray = [2, 5, 98, 2, 13]
jumbledArray.sorted() // [2, 2, 5, 13,98]
// END playground_closure_sort

// BEGIN playground_closure_sort_2
let numbers = [2,1,56,32,120,13]
var numbersSorted = numbers.sorted(by: {
    (n1: Int, n2: Int) -> Bool in return n2 > n1
})
// [1, 2, 13, 32, 56, 120]
// END playground_closure_sort_2

// BEGIN playground_closure_sort_3
let numbersSortedReverse = numbers.sorted(by: {n1, n2 in return n1 > n2})
//[120, 56, 32, 13, 2, 1]
// END playground_closure_sort_3

// BEGIN playground_closure_sort_4
var numbersSortedAgain = numbers.sorted(by: { $1 > $0
}) // [1, 2, 13, 32, 56, 120]
// END playground_closure_sort_4

// BEGIN playground_closure_sort_5
var numbersSortedReversedAgain = numbers.sorted { $0 > $1
} // [120, 56, 32, 13, 2, 1]
// END playground_closure_sort_5

// BEGIN playground_closure_sort_6
var numbersSortedReversedOneMoreTime = numbers.sorted { $0 > $1 }
// [120, 56, 32, 13, 2, 1]
// END playground_closure_sort_6

// BEGIN playground_closure_variable
var comparator = {(a: Int, b:Int) in a < b}
comparator(1,2) // true
// END playground_closure_variable

// BEGIN playground_convenience_defer
func doSomeWork() {
    print("Getting started!")
    defer {
        print("All done!")
    }
    print("Getting to work!")
}
doSomeWork()
// Prints "Getting started!", "Getting to work!" and "All done!", in that order
// END playground_convenience_defer

// BEGIN playground_convenience_guard_1
func doAThing(){
    guard 2+2 == 4 else {
        print("The universe makes no sense")
        return // this is mandatory!
    }
    print("We can continue with our daily lives")
}
// END playground_convenience_guard_1

// BEGIN playground_convenience_guard_2
func doSomeStuff(importantVariable: Int?)
{
    guard let importantVariable = importantVariable else
    {
        // we need the variable to exist to continue
        return
    }
    print("doing our important work with \(importantVariable)")
}
doSomeStuff(importantVariable: 3) // works as expected
doSomeStuff(importantVariable: nil) // exits function on the guard statement
// END playground_convenience_guard_2






































//: [Next](@next)
