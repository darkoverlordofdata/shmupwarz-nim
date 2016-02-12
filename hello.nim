type Animal = ref object of RootObj
  ## Animal type
  name: string
  age: int

type Dog = ref object of Animal

method vocalize(this: Animal): string =
  ##
  ##
  result = "..."

method ageHumanYrs(this: Animal): int =
  ##
  ##
  result = this.age

  ## Dog!
method vocalize(this: Dog): string =
  ##
  ##
  result = "woof"
  
method ageHumanYrs(this: Dog): int =
  ##
  ##
  result = this.age * 7

type Cat = ref object of Animal
  ## Cat!
method vocalize(this: Cat): string =
  ##
  ##
  result = "meow"


var animals: seq[Animal] = @[]
animals.add(Dog(name: "Sparky", age: 10))
animals.add(Cat(name: "Mitten", age: 10))

for a in animals:
  echo a.vocalize()
  echo a.ageHumanYrs()
