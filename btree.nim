import NimMan/Game
import bosco/ECS
# type
#   BinaryTreeObj[T] = object # BinaryTree is a generic type with
#                             # with generic param ``T``
#     le, ri: BinaryTree[T]   # left and right subtrees; may be nil
#     data: T                 # the data stored in a node
#   BinaryTree*[T] = ref BinaryTreeObj[T] # type that is exported
#
# proc newNode*[T](data: T): BinaryTree[T] =
#   # constructor for a node
#   new(result)
#   result.data = data
#
# method add*[T](root: var BinaryTree[T], n: BinaryTree[T]) =
#   # insert a node into the tree
#   if root == nil:
#     root = n
#   else:
#     var it = root
#     while it != nil:
#       # compare the data items; uses the generic ``cmp`` proc
#       # that works for any type that has a ``==`` and ``<`` operator
#       var c = cmp(it.data, n.data)
#       if c < 0:
#         if it.le == nil:
#           it.le = n
#           return
#         it = it.le
#       else:
#         if it.ri == nil:
#           it.ri = n
#           return
#         it = it.ri
#
# method add*[T](root: var BinaryTree[T], data: T) =
#   # convenience proc:
#   add(root, newNode(data))
#
# iterator preorder*[T](root: BinaryTree[T]): T =
#   # Preorder traversal of a binary tree.
#   # Since recursive iterators are not yet implemented,
#   # this uses an explicit stack (which is more efficient anyway):
#   var stack: seq[BinaryTree[T]] = @[root]
#   while stack.len > 0:
#     var n = stack.pop()
#     while n != nil:
#       yield n.data
#       add(stack, n.ri)  # push right subtree onto the stack
#       n = n.le          # and follow the left pointer
#
# var
#   root: BinaryTree[string] # instantiate a BinaryTree with ``string``
#   rootz: BinaryTree[int] # instantiate a BinaryTree with ``int``
# add(root, newNode("hello")) # instantiates ``newNode`` and ``add``
# add(root, "world")          # instantiates the second ``add`` proc
# for str in preorder(root):
#   stdout.writeLine(str)
var game: Game
game.Init()
game.Run()
# type
#   Paper = object
#     name: string
#
#   Bendable = generic x
#     bend(x)
#
# method bend(p: Paper): Paper = Paper(name: "bent-" & p.name)
#
# var p = Paper(name: "red")
# echo p is Bendable  # prints 'true'
# echo 42 is Bendable # prints 'false'
#
# #echo "Press return to proceed"
# #discard stdin.readLine();
