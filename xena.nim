type
  Animal* = ref object of RootObj
    age*: int
    name*: string

  Cat* = ref object of Animal
    playfulness*: float

  Tiger* = ref object of Cat
    stripes*: int

  UndefinedMethodError =
    object of Exception

template undefined*() =
  raise newException(UndefinedMethodError, "undefined method")

# method increaseAge* (this: var Animal) : void {.base.} = undefined
proc increaseAge* (this: Cat) : void = this.age.inc()
proc increaseAge* (this: Tiger) : void = this.age += 2

var c = Cat(name: "Tom")
c.increaseAge()
echo c.name, " ", c.age

var t = Tiger(name: "Tony")
t.increaseAge()
echo t.name, " ", t.age

for x in [Tiger(name: "Xena"), Cat(name: "Osa")]:
  x.increaseAge()
  echo x.name," is ", x.age
