from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Screens.MessageBox import MessageBox
from Components.MenuList import MenuList
from Components.Label import Label
from Components.ActionMap import ActionMap
from Components.Sources.StaticText import StaticText
from Screens.VirtualKeyBoard import VirtualKeyBoard
from urllib import quote
from enigma import eDVBDB

class LiveStreamingLinksHeader(Screen):
	skin = """
	<screen position="center,center" size="300,200" title="">
		<widget name="menu" position="10,10" size="280,190" scrollbarMode="showOnDemand" />
	</screen>"""

	def __init__(self, session):
		self.skin = LiveStreamingLinksHeader.skin
		Screen.__init__(self, session)
		self["actions"] = ActionMap(["SetupActions"],
		{
			"ok": self.keyOk,
			"cancel": self.keyCancel,
		}, -2)

		self.list= []
		self.list.append('http://')
		self.list.append('rtmp://')
		self.list.append('rtsp://')
		self.list.append('mms://')
		self.list.append('m3u://')
		self.list.append('pls://')
		self.list.append('asx://')
		self["menu"] = MenuList(self.list)

		self.onLayoutFinish.append(self.layoutFinish)

	def layoutFinish(self):
		self.setTitle(_("Select URL type"))

	def keyOk(self):
		self.close(self.list[self["menu"].getSelectedIndex()])

	def keyCancel(self):
		self.close('cancel')

class LiveStreamingLinks(Screen):
	DIR_ENIGMA2 = '/etc/enigma2/'
	skin = """
	<screen position="center,center" size="500,380" title="">
		<widget name="menu" position="10,5" size="480,280" scrollbarMode="showOnDemand" />
		<widget source="statusbar" render="Label" position="10,290" zPosition="10" size="480,40" halign="center" valign="center" font="Regular;22" foregroundColor="#000000" transparent="1" />
		<ePixmap pixmap="skin_default/buttons/red.png" position="80,330" size="140,40" alphatest="on" />
		<ePixmap pixmap="skin_default/buttons/green.png" position="280,330" size="140,40" alphatest="on" />
		<widget source="key_red" render="Label" position="80,330" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#9f1313" foregroundColor="#ffffff" transparent="1" />
		<widget source="key_green" render="Label" position="280,330" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#1f771f" foregroundColor="#ffffff" transparent="1" />
	</screen>"""

	def __init__(self, session):
		self.skin = LiveStreamingLinks.skin
		Screen.__init__(self, session)
		self["key_red"] = StaticText(_("Cancel"))
		self["key_green"] = StaticText(_("Ok"))
		self["actions"] = ActionMap(["SetupActions", "ColorActions"],
		{
			"ok": self.keyOk,
			"save": self.keyOk,
			"cancel": self.keyCancel,
			"green": self.keyOk,
			"red": self.keyCancel,
		}, -2)

		self["statusbar"] = StaticText(_("Select a bouquet to add a channel to"))

		self.list= []
		self["menu"] = MenuList(self.list)

		self.onLayoutFinish.append(self.createTopMenu)

	def initSelectionList(self):
		self.list = []
		self["menu"].setList(self.list)

	def createTopMenu(self):
		self.setTitle(_("Add stream URL"))
		self.initSelectionList()
		self.list= []
		tmpList = []
		tmpList = self.readFile(self.DIR_ENIGMA2 + 'bouquets.tv')
		if tmpList != '':
			for x in tmpList:
				if 'FROM BOUQUET \"' in x:
					tmp = x.split("\"")
					if len(tmp) == 3:
						self.list.append((tmp[1].split('.')[1], tmp[1]))
		self["menu"].setList(self.list)


	def keyOk(self):
		if len(self.list) == 0:
			return
		self.name = ''
		self.url = ''
		self.session.openWithCallback(self.nameCallback, VirtualKeyBoard, title = _("Enter name"), text = '')

	def nameCallback(self, res):
		if res:
			self.name = res
			self.session.openWithCallback(self.urlTypeCallback, LiveStreamingLinksHeader)

	def urlTypeCallback(self, res):
		if res:
			if res != 'cancel':
				self.session.openWithCallback(self.urlCallback, VirtualKeyBoard, title = _("Enter URL"), text = res)

	def urlCallback(self, res):
		if res:
			self.url = res
			out = ''
			tmpList = []
			fileName = self.DIR_ENIGMA2 + self.list[self["menu"].getSelectedIndex()][1]
			tmpList = self.readFile(fileName)
			if tmpList == '':
				return
			for x in tmpList:
				out += x
			out += '#SERVICE 4097:0:0:0:0:0:0:0:0:0:%s:%s\r\n' % (quote(self.url), quote(self.name))
			fp = open(fileName, 'w')
			fp.write(out)
			fp.close()
			db = eDVBDB.getInstance()
			db.reloadServicelist()
			db.reloadBouquets()

	def keyCancel(self):
		self.close()

	def readFile(self, name):
		try:
			lines = open(name).readlines()
			return lines
		except:
			return ''
			pass

def main(session, **kwargs):
	session.open(LiveStreamingLinks)

def Plugins(**kwargs):
	return [PluginDescriptor(name = _("Add stream URL"), description = _("Add a streaming url to your channellist"), where = PluginDescriptor.WHERE_PLUGINMENU, fnc = main)]
