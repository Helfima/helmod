-------------------------------------------------------------------------------
-- Class to build Download panel
--
-- @module Download
-- @extends #Form
--

Download = newclass(Form)

local transfert_mode = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Download] init
--
function Download:onInit(parent)
  self.panelCaption = ({"helmod_download-panel.title"})
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#Download] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function Download:onBeforeEvent(event)
  -- close si nouvel appel
  return true
end


-------------------------------------------------------------------------------
-- Get or create other Download panel
--
-- @function [parent=#Download] getDownloadPanel
--
function Download:getDownloadPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["download"] ~= nil and content_panel["download"].valid then
    return content_panel["download"]
  end
  return ElementGui.addGuiFrameV(content_panel, "download", helmod_frame_style.panel, {"helmod_common.download"})
end

-------------------------------------------------------------------------------
-- Get or create other Upload panel
--
-- @function [parent=#Download] getUploadPanel
--
function Download:getUploadPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["upload"] ~= nil and content_panel["upload"].valid then
    return content_panel["upload"]
  end
  return ElementGui.addGuiFrameV(content_panel, "upload", helmod_frame_style.panel, {"helmod_common.upload"})
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Download] onEvent
--
-- @param #LuaEvent event
--
function Download:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  -- import
  if event.action == "download-model" then
    local download_panel = self:getDownloadPanel()
    local text_box = download_panel["data-text"]
    Logging:debug(self.classname, "data_string", text_box.text)
    local data_table = Converter.read(text_box.text)
    Logging:debug(self.classname, "data_table", data_table)
    if data_table ~= nil then
      local model = Model.newModel()
      model.time = data_table.time
      ModelBuilder.copyModel(data_table)
      ModelCompute.update()
      Controller:send("on_gui_refresh", event)
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Download] Download
--
-- @param #LuaEvent event
--
function Download:onUpdate(event)
  self:updateDownload(event)
end

-------------------------------------------------------------------------------
-- Update about Download
--
-- @function [parent=#Download] updateDownload
--
-- @param #LuaEvent event
--
function Download:updateDownload(event)
  Logging:debug(self.classname, "updateDownload()", event)
  local data_string = ""
  -- export
  if event.item1 == "upload" then
    local download_panel = self:getUploadPanel()
    download_panel.clear()
    local model = Model.getModel() 
    data_string = Converter.write(model)
    local text_box = ElementGui.addGuiTextbox(download_panel, "data-text", data_string, "helmod_textbox_default")
    ElementGui.addGuiButton(download_panel, self.classname.."=CLOSE", nil, "helmod_button_default", ({"helmod_button.close"}))
  end
  -- import
  if event.item1 == "download" then
    local download_panel = self:getDownloadPanel()
    download_panel.clear()
    local text_box = ElementGui.addGuiTextbox(download_panel, "data-text", data_string, "helmod_textbox_default")
    ElementGui.addGuiButton(download_panel, self.classname.."=download-model=ID=", "download", "helmod_button_default", ({"helmod_common.download"}))
    ElementGui.addGuiButton(download_panel, self.classname.."=CLOSE", nil, "helmod_button_default", ({"helmod_button.close"}))
  end
end