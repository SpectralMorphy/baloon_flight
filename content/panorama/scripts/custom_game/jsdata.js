var _G = GameUI.CustomUIConfig();

_G.__JsData_tData = _G.__JsData_tData || {};
_G.__JsData_tListens = _G.__JsData_tListens || {};

_G.GetJsData = function (sKey) {
  return _G.__JsData_tData[sKey];
};

_G.ListenJsData = function (sKey, fCallback) {
  let qListens = _G.__JsData_tListens[sKey] || (_G.__JsData_tListens[sKey] = []);
  qListens.push(fCallback);

  let xData = _G.GetJsData(sKey);
  if (xData != null) {
    fCallback(xData);
  }
};

_G.UnlistenJsData = function (sKey, fCallback) {
  let qListens = _G.__JsData_tListens[sKey];
  if (!qListens) return;

  let nIndex = qListens.indexOf(fCallback);
  if (nIndex < 0) return;

  qListens.splice(nIndex, 1);
};

function __JsData_Init() {
  $.Msg('['+Game.GetGameTime()+']: jsdata cl request (init)');
  GameEvents.SendCustomGameEventToServer('sv_jsdata_request', {});
}

GameEvents.Subscribe('cl_jsdata_set', function (t) {
  if(t.sKey == 'CameraSettings') $.Msg('['+Game.GetGameTime()+']: jsdata set camera');
  _G.__JsData_tData[t.sKey] = t.xData;

  let qListens = _G.__JsData_tListens[t.sKey];
  if (qListens) qListens.forEach((fCallback) => fCallback(t.xData));
});

GameEvents.Subscribe('cl_activate', function () {
  $.Msg('['+Game.GetGameTime()+']: jsdata activate');
  __JsData_Init();
});

__JsData_Init();
