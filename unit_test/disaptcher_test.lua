require "core.global"
require "core.class"
require "core.defines"
require "core.logging"
require "controller.DispatcherController"

Logging:new()
Logging.console = false

local MyDispatcher = DispatcherController("HMDispatcher")

MyClassTest = newclass(Object,function(base,classname)
  Object.init(base,classname)
end)

function MyClassTest:print(event)
  print(self.classname, event.type, event.echo)
end

local MyClass1 = MyClassTest("MyClassTest1")
local MyClass2 = MyClassTest("MyClassTest2")
local MyClass3 = MyClassTest("MyClassTest3")


print("----------------------------")
MyDispatcher:bind("print", MyClass1, MyClass1.print)
MyDispatcher:bind("print", MyClass2, MyClass2.print)
MyDispatcher:bind("print", MyClass3, MyClass3.print)

MyDispatcher:send("print", {echo="event MyClass1"}, "MyClassTest1")

print("----------------------------")
MyDispatcher:send("print", {echo="event all"})

print("----------------------------")
MyDispatcher:unbind("print", MyClass3, MyClass3.print)
MyDispatcher:bind("other", MyClass3, MyClass3.print)
MyDispatcher:send("print", {echo="event all"})

print("----------------------------")
MyDispatcher:unbind("print", MyClass3, MyClass3.print)
MyDispatcher:send("print", {echo="event all"})

print("----------------------------")
MyDispatcher:unbind("print", MyClass1)
MyDispatcher:send("print", {echo="event all"})

print("----------------------------")
MyDispatcher:send("other", {echo="event all"})

print("----------------------------")
print(Logging:objectToString(MyDispatcher))
