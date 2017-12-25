-------------------------------------------------------------------------------
-- Class to build Download panel
--
-- @module Download
-- @extends #Dialog
--

Download = setclass("HMDownload", Dialog)

local transfert_mode = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Download] init
--
-- @param #Controller parent parent controller
--
function Download.methods:init(parent)
  self.panelCaption = ({"helmod_download-panel.title"})
  self.parent = parent
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Download] getParentPanel
--
-- @return #LuaGuiElement
--
function Download.methods:getParentPanel()
  return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Download] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function Download.methods:onOpen(event, action, item, item2, item3)
  -- close si nouvel appel
  return true
end


-------------------------------------------------------------------------------
-- Get or create other Download panel
--
-- @function [parent=#Download] getDownloadPanel
--
function Download.methods:getDownloadPanel()
  local panel = self:getPanel()
  if panel["download"] ~= nil and panel["download"].valid then
    return panel["download"]
  end
  return ElementGui.addGuiFrameV(panel, "download", helmod_frame_style.panel, {"helmod_common.download"})
end

-------------------------------------------------------------------------------
-- Get or create other Upload panel
--
-- @function [parent=#Download] getUploadPanel
--
function Download.methods:getUploadPanel()
  local panel = self:getPanel()
  if panel["upload"] ~= nil and panel["upload"].valid then
    return panel["upload"]
  end
  return ElementGui.addGuiFrameV(panel, "upload", helmod_frame_style.panel, {"helmod_common.upload"})
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Download] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Download.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent()", action, item, item2, item3)
  -- import
  if action == "download-model" then
    local download_panel = self:getDownloadPanel()
    local text_box = download_panel["data-text"]
    --Logging:debug(self:classname(), "data_string", text_box.text)
    local data_table = Converter.read(text_box.text)
    --Logging:debug(self:classname(), "data_table", data_table)
    if data_table ~= nil then
      local model = Model.newModel()
      model.time = data_table.time
      Model.copyModel(data_table)
      Model.update()
      Controller.refreshDisplay()
    end
  end
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Download] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Download.methods:afterOpen(event, action, item, item2, item3)
  self:updateDownload(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update about Download
--
-- @function [parent=#Download] updateDownload
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Download.methods:updateDownload(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateDownload():", action, item, item2, item3)
  local data_string = ""
  -- export
  if item == "upload" then
    local download_panel = self:getUploadPanel()
    local model = Model.getModel() 
    data_string = Converter.write(model)
    local text_box = ElementGui.addGuiTextbox(download_panel, "data-text", data_string, "helmod_textbox_default")
    ElementGui.addGuiButton(download_panel, self:classname().."=CLOSE", nil, "helmod_button_default", ({"helmod_button.close"}))
  end
  -- import
  if item == "download" then
    local download_panel = self:getDownloadPanel()
    local text_box = ElementGui.addGuiTextbox(download_panel, "data-text", data_string, "helmod_textbox_default")
    ElementGui.addGuiButton(download_panel, self:classname().."=download-model=ID=", "download", "helmod_button_default", ({"helmod_common.download"}))
    ElementGui.addGuiButton(download_panel, self:classname().."=CLOSE", nil, "helmod_button_default", ({"helmod_button.close"}))
  end
end