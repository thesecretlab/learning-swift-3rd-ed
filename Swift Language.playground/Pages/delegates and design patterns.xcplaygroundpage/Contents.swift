//: [Previous](@previous)

import Foundation

// BEGIN playground_delegate_example
// Define a protocol that has a function called handleIntruder
protocol HouseSecurityDelegate {
    
    // We don't define the function here, but rather
    // indicate that any class that is a HouseSecurityDelegate
    // is required to have a handleIntruder() function
    func handleIntruder()
}

class House {
    // The delegate can be any object that conforms
    // to the HouseSecurityDelegate protocol
    var delegate : HouseSecurityDelegate?
    
    func burglarDetected() {
        // Check to see if the delegate is there, then call it
        delegate?.handleIntruder()
    }
}

class GuardDog : HouseSecurityDelegate {
    func handleIntruder() {
        print("Releasing the hounds!")
    }
}

let myHouse = House()
myHouse.burglarDetected() // does nothing

let theHounds = GuardDog()
myHouse.delegate = theHounds
myHouse.burglarDetected() // prints "Releasing the hounds!"
// END playground_delegate_example

// BEGIN playground_delegate_example_2
class KillerRobot : HouseSecurityDelegate {
    func handleIntruder() {
        print("Deploying T-800 battle chassis")
    }
}

let killerRobot = KillerRobot()
myHouse.delegate = killerRobot
myHouse.burglarDetected() // prints "Deploying T-800 battle chassis"
// END playground_delegate_example_2


// BEGIN playground_error_enum
enum BankError : Error {
    // Not enough money in the account
    case notEnoughFunds
    
    // Can't create an account with negative money
    case cannotBeginWithNegativeFunds
    
    // Can't make a negative deposit or withdrawal
    case cannotMakeNegativeTransaction(amount:Float)
}
// END playground_error_enum
// BEGIN playground_error_class
// A simple bank account class
class BankAccount {
    
    // The amount of money in the account
    private (set) var balance : Float = 0.0
    
    // Initializes the account with an amount of money.
    // Throws an error if you try to create the account
    // with negative funds.
    init(amount:Float) throws {
        
        // Ensure that we have a non-negative amount of money
        guard amount > 0 else {
            throw BankError.cannotBeginWithNegativeFunds
        }
        balance = amount
    }
    
    // Adds some money to the account
    func deposit(amount: Float) throws {
        
        // Ensure that we're trying to deposit a non-negative amount
        guard amount > 0 else {
            throw BankError.cannotMakeNegativeTransaction(amount: amount)
        }
        balance += amount
    }
    
    // Withdraws money from the bank account
    func withdraw(amount : Float) throws {
        
        // Ensure that we're trying to deposit a non-negative amount
        guard amount > 0 else {
            throw BankError.cannotMakeNegativeTransaction(amount: amount)
        }
        
        // Ensure that we have enough to withdraw this amount
        guard balance >= amount else {
            throw BankError.notEnoughFunds
        }
        
        balance -= amount
    }
}
// END playground_error_class
// BEGIN playground_error_do
do {
    let vacationFund = try BankAccount(amount: 5)
    
    try vacationFund.deposit(amount: 5)
    
    try vacationFund.withdraw(amount: 11)
    
} catch let error as BankError {
    
    // Catch any BankError that was thrown
    switch (error) {
    case .notEnoughFunds:
        print("Not enough funds in account!")
    case .cannotBeginWithNegativeFunds:
        print("Tried to start an account with negative money!")
    case .cannotMakeNegativeTransaction(let amount):
        print("Tried to do a transaction with a negative amount of \(amount)!")
    }
    
} catch let error {
    // (Optional:) catch other types of errors
}
// END playground_error_do
// BEGIN playground_error_try1
let secretBankAccountOrNot = try? BankAccount(amount: -50) // nil
// END playground_error_try1
// BEGIN playground_error_try2
let secretBankAccount = try! BankAccount(amount: 50)
// the above call will exist or crash if we put in an invalid amount
// END playground_error_try2

// BEGIN playground_memory_class
class Human {
    weak var bestFriend : Dog?
    
    var name : String
    
    init(name:String){
        self.name = name
    }
    
    deinit {
        print("\(name) is being removed")
    }
}
class Dog {
    weak var friendBeast : Human?
    
    var name : String
    
    init(name:String){
        self.name = name
    }
    deinit {
        print("\(name) is being removed")
    }
}
// END playground_memory_class

// BEGIN playground_memory_vars
var turner : Human? = Human(name:"Turner")
var hooch : Dog? = Dog(name:"Hooch")
// END playground_memory_vars

// BEGIN playground_memory_properties
turner?.bestFriend = hooch
hooch?.friendBeast = turner
// END playground_memory_properties

// BEGIN playground_memory_nil
turner = nil // "Turner is being removed"
hooch = nil // "Hooch is being removed"
// END playground_memory_nil

// BEGIN playground_memory_unowned_class
class Person {
    var name : String
    var passport : Passport?
    
    init(name: String) {
        self.name = name
    }
    
    deinit { print("\(name) is being removed") }
}
class Passport {
    var number : Int
    unowned let person : Person
    
    init(number: Int, person: Person) {
        self.number = number
        self.person = person
    }
    
    deinit { print("Passport \(number) is being removed") }
}
// END playground_memory_unowned_class

// BEGIN playground_memory_unowned_create
var viktor : Person? = Person(name: "Viktor Navorski")
viktor!.passport = Passport(number: 1234567890, person: viktor!)

viktor?.passport?.number // 1234567890
// END playground_memory_unowned_create

// BEGIN playground_memory_unowned_nil
viktor = nil
// prints "Viktor Navorski is being removed
// print "Passport 1234567890 is being removed"
// END playground_memory_unowned_nil

//: [Next](@next)
