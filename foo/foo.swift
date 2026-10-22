import Cocoa

print("hello")
var foo = 2
print(foo)

let myInt = Int.random(in: 1...1000)
print(myInt)
let score = 3.1 // double implicit
print(score)

var goodDogs = true
print(goodDogs)
var isSaved = false
isSaved.toggle() // flips it

let name = "William"
let message = "I'm \(name)."
print(message)

var colors = ["red", "green"]
print(colors)

let employee = [
    "name": "Will",
    "job": "progammer"
]

print(employee["job", default: "unknown"])

enum Weekday {
    case monday, tuesday, wednesday, thursday, friday
}
var day = Weekday.monday
print(day)
day = .friday
print(day)

