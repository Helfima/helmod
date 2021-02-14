-------------------------------------------------------------------------------
---Class to build form with current model
---@class FormModel
FormModel = newclass(Form,function(base,classname)
    Form.init(base,classname)
    base.parameter_objects = string.format("%s_%s", classname, "objects")
end)

-------------------------------------------------------------------------------
---On before event
---@param event LuaEvent
function FormModel:onBeforeOpen(event)
    User.setParameter(self.parameter_objects, {name=self.parameter_objects, model=event.item1, block=event.item2, recipe=event.item3})
end

-------------------------------------------------------------------------------
---Get objects with current parameter
---@return model, block, recipe
function FormModel:getParameterObjects()
    local parameter_objects = User.getParameter(self.parameter_objects)
    local model, block, recipe = Model.getParameterObjects(parameter_objects)
    return model, block, recipe
end
