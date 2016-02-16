# types.nim
const PI = 3.1415

type
  AbstractShape* = ref object of RootObj
  Circle* = ref object of AbstractShape
    name* : string
    radius*: float
  Rectangle* = ref object of AbstractShape
    name* : string
    a*, b*: float

type
  UndefinedMethodError =
    object of Exception

type Animal = ref object of RootObj
  age: int
  name: string

type Cat = ref object of Animal
  playfulness: float

proc increase_age(this: var Cat) =
  this.age.inc()

var c = Cat(name: "Tom")
c.increase_age()
echo c.name, " ", c.age



template undefined*() =
  raise newException(UndefinedMethodError, "undefined method")

method name*(this: AbstractShape): string {.base.} = undefined
method area*(this: AbstractShape): float = undefined
method circumference*(this: AbstractShape): float {.base.} = undefined

method name*(this: Circle): string = this.name
method area*(this: Circle): float = this.radius * this.radius * PI
method circumference*(this: Circle): float = 2 * this.radius * PI

method name*(this: Rectangle): string = this.name
method area*(this: Rectangle): float = this.a * this.b
method circumference*(this: Rectangle): float = 2 * this.a * this.b

for x in [Circle(name: "circle", radius: 10), Rectangle(name: "rect", a: 4, b: 5)]:
  echo "area of ", x.name, " = ", x.area
  echo "circumference of ", x.name, " = ", x.circumference

var d = Circle(name: "circle", radius: 10)
echo d.name, d.radius, d.area, d.circumference
