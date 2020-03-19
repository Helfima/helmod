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
-- Get or create other Download panel
--
-- @function [parent=#Download] getDownloadPanel
--
function Download:getDownloadPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["download"] ~= nil and content_panel["download"].valid then
    return content_panel["download"]
  end
  return GuiElement.add(content_panel, GuiFrameV("download"):style(helmod_frame_style.panel):tooltip({"helmod_common.download"}))
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
  return GuiElement.add(content_panel, GuiFrameV("upload"):style(helmod_frame_style.panel):tooltip({"helmod_common.upload"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Download] onEvent
--
-- @param #LuaEvent event
--
function Download:onEvent(event)
  -- import
  if event.action == "download-model" then
    local download_panel = self:getDownloadPanel()
    local text_box = download_panel["data-text"]
    local data_table = Converter.read(text_box.text)
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
  local data_string = ""
  -- export
  if event.item1 == "upload" then
    local download_panel = self:getUploadPanel()
    download_panel.clear()
    local model = Model.getModel() 
    data_string = Converter.write(model)
    local text_box = GuiElement.add(download_panel, GuiTextBox("data-text"):text(data_string))
    GuiElement.add(download_panel, GuiButton(self.classname, "CLOSE"):caption({"helmod_button.close"}))
  end
  -- import
  if event.item1 == "download" then
    local download_panel = self:getDownloadPanel()
    download_panel.clear()
    local text_box = GuiElement.add(download_panel, GuiTextBox("data-text"):text(data_string))
    GuiElement.add(download_panel, GuiButton(self.classname, "download-model", "download"):style("helmod_button_default"):caption({"helmod_common.download"}))
    GuiElement.add(download_panel, GuiButton(self.classname, "CLOSE"):caption({"helmod_button.close"}))
  end
end