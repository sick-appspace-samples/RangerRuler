--[[----------------------------------------------------------------------------

  Application Name: RangerRuler

  Description:
  Retrieving ScanImages from Ranger or Ruler camera and view them as a point cloud.

  Required: Ranger or Ruler camera

  This sample connects to a remote Ranger/Ruler device and retrieves ScanImages from it.
  The images are transformed to point cloud data and displayed in the viewer.

  To view this sample a Ranger or Ruler camera must be connected via ethernet.
  The SensorIP and ConfigFilePath must be set accordingly.
  After starting the script, the results can be seen in the PointCloud view.

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- luacheck: globals gView gConfig gRangerRuler gTimer gOnNewData gOnExpired

-- Configure IP of sensor here
local SensorIp = '192.168.0.11'

-- Set parameter and LUT file paths
local ConfigFilePath = 'resources/Ranger.prm'
local LutFilePath = 'resources/Calibration.lut'
-- Use Hi3D algorithm (must be in named in prm file)
local ComponentName = 'Hi3D 1'

-- Alternative: Uncomment these line for Ruler camera. Comment out the other lines above
-- ConfigFilePath = "resources/Ruler.prm"
-- ComponentName = "HorMax 1"

gView = View.create()
gView:setID('viewer3D')

gConfig = ScanImages.Provider.RangerRulerConfig.create()
ScanImages.Provider.RangerRulerConfig.loadConfigXML(gConfig, ConfigFilePath)
-- Optional, use calibration file, if not use file in device
ScanImages.Provider.RangerRulerConfig.loadCalibrationLUT(gConfig, LutFilePath)

gRangerRuler = ScanImages.Provider.RemoteRangerRuler.create()
ScanImages.Provider.RemoteRangerRuler.register(gRangerRuler, 'OnNewData', 'gOnNewData')
ScanImages.Provider.RemoteRangerRuler.setConfig(gRangerRuler, gConfig)
ScanImages.Provider.RemoteRangerRuler.setIPAddress(gRangerRuler, SensorIp)
ScanImages.Provider.RemoteRangerRuler.setMode(gRangerRuler, 'MEASUREMENT')
ScanImages.Provider.RemoteRangerRuler.start(gRangerRuler)

gTimer = Timer.create()
Timer.register(gTimer, 'OnExpired', 'gOnExpired')
Timer.setPeriodic(gTimer, false)
Timer.setExpirationTime(gTimer, 30000)
Timer.start(gTimer)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Definition of the callback function which is registered at the driver
-- data contains the image scans
-- encoder contains the corresponding encoder value
function gOnNewData(data, _)
  local pointCloud, _ = ScanImages.toPointCloud(data, ComponentName, 0.1)
  View.view(gView, pointCloud)
end

function gOnExpired()
  ScanImages.Provider.RemoteRangerRuler.stop(gRangerRuler)
end

--End of Function and Event Scope------------------------------------------------
