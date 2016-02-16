import math

type Shape = ref object
  name: string
  area: proc(): float
  circumference: proc(): float

proc makeCircle(radius: float): Shape =
  proc area(): float = radius * radius * PI
  proc circumference(): float = 2 * radius * PI
  Shape(name: "circle", area: area, circumference: circumference)

proc makeRectangle(a, b: float): Shape =
  proc area(): float = a * b
  proc circumference(): float = 2*(a+b)
  Shape(name: "rectangle", area: area, circumference: circumference)

let c = makeCircle(10)
let r = makeRectangle(4, 5)
for x in [c, r]:
  echo "area of ", x.name, " = ", x.area()
  echo "circumference of ", x.name, " = ", x.circumference()
