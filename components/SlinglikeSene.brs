function init()
	? "[slingLikesene] init"
    'this is my first commit test to git
    m.overhang = m.top.findnode("overhang")
    m.mainposter=m.top.findnode("mainPoster")
    m.itemmask = m.top.findNode("itemMask")
    m.descriptionLabel = m.top.findNode("descriptionLabel")
    m.overhang.title =  ""
    m.postergrid = m.top.findNode("examplePosterGrid")
    m.error_dialog = m.top.findNode("error_dialog")
	m.videoplayer = m.top.findNode("videoplayer")
    m.postergrid.setFocus(true)
    m.top.observeField("posterItem_selected","showdetailGrid")
    m.theRowList = m.top.FindNode("theRowList")  
    populateGrid()
    m.theRowList.setFocus(false)
    m.theRowList.visible="false"
    m.top.ObserveField("rowItem_selected","onRowItemSelected")
    m.top.observeField("rowItemFocused", "onRowItemFocused")
    initializeVideoPlayer()



end function
'-------------------------------------------------------------
sub populateGrid()
      m.readPosterGridTask = createObject("roSGNode", "ContentReader")
      
      m.readPosterGridTask.contenturi = "pkg:/resources/posterJSon.json"
      m.readPosterGridTask.observeField("content", "showpostergrid")
      m.readPosterGridTask.control = "RUN"
      m.postergrid.setFocus(true)
end sub
'-------------------------------------------------------------
 sub showpostergrid()
      m.postergrid.content = m.readPosterGridTask.content
    end sub

'-------------------------------------------------------------
sub showdetailGrid(obj)
'print "in showdetailgrid"
m.theRowList.visible="true"
m.theRowList.setFocus(true)

? "showdetailGrid field: ";obj.getField()
? "showdetailGrid data: ";obj.getData()

    list = m.top.findNode("examplePosterGrid")

    ? "showdetailGrid selected ContentNode: ";list.content.getChild(obj.getData())
    item = list.content.getChild(obj.getData())
   loadFeed(item.getchild(0).feed_url)

   ' print item.getchild(0).feed_url




end sub
'-------------------------------------------------------------
function updateConfig(params)
    categories = params.config.categories
    contentNode = createObject("roSGNode","ContentNode")
    for each category in categories
        node = createObject("roSGNode","grid_node")
        node.title = category.title
        node.feed_url = params.config.host + category.feed_url
        contentNode.appendChild(node)
    end for
    m.postergrid.content = contentNode
end function
'-------------------------------------------------------------
sub loadFeed(url)
	m.feed_task = createObject("roSGNode", "load_feed_task")
	m.feed_task.observeField("response", "onFeedResponse")
	m.feed_task.observeField("error", "onFeedError")
	m.feed_task.url = url
	m.feed_task.control = "RUN"
end sub
'-------------------------------------------------------------
sub onFeedError(obj)
'showErrorDialog(obj.getData())
print "error in onfeedError" obj.getData()
end sub
'-------------------------------------------------------------
sub onFeedResponse(obj)
	response = obj.getData()
	data = parseJSON(response)
	if data <> invalid and data.items <> invalid
		'params = {config:obj.getData()}
       params = {config:data}
        m.theRowList.callFunc("GetRowListContent",params)
	else
		'showErrorDialog("Feed data malformed.")
        print "feed data malformed"
	end if
end sub
'-------------------------------------------------------------
sub onRowItemFocused(obj)
print "Inside the on row focused"
m.mainposter.visible = "true"
? "onRowItemFocused field: ";obj.getField()
? "onRowItemFocused data: ";obj.getData()
row = m.theRowList.rowItemFocused[0] 
col = m.theRowList.rowItemFocused[1]

  list = m.theRowList.content
  ? "onRowItemFocused selected ContentNode: ";list.getChild(row).getChild(col)
  item = list.getChild(row).getChild(col)
  
   
    m.mainPoster.uri = item.posterUrl
    m.descriptionLabel.text = item.description
    m.descriptionLabel.wrap = "true"
   ' m.descriptionLabel.numLines = "10"
    m.descriptionLabel.visible = "true"


end sub

'-------------------------------------------------------------
sub onRowItemSelected(obj)
print "now in rowItemSelected"
? "onRowItemSelected field: ";obj.getField()
? "onRowItemSelected data: ";obj.getData()
row = m.theRowList.rowItemSelected[0] 
col = m.theRowList.rowItemSelected[1]

  list = m.theRowList.content
   ? "onRowItemSelected selected ContentNode: ";list.getChild(row).getChild(col)
    item = list.getChild(row).getChild(col)
     print row
     print col
   
        print   list.getChild(row).getChild(col)

     videoContent = createObject("RoSGNode", "ContentNode") 
      videoContent.url =  list.getChild(row).getChild(col).url
      videoContent.streamformat = "hls"     

    m.theRowList.visible=false
	m.overhang.visible = false
	m.videoplayer.visible = true
	m.videoplayer.setFocus(true)
	m.videoplayer.content = videoContent
	m.videoplayer.control = "play"



end sub
'-------------------------------------------------------------

sub initializeVideoPlayer()
	m.videoplayer.EnableCookies()
	m.videoplayer.setCertificatesFile("common:/certs/ca-bundle.crt")
	m.videoplayer.InitClientCertificates()
    m.videoplayer.notificationInterval=1
	m.videoplayer.observeFieldScoped("position", "onPlayerPositionChanged")
	m.videoplayer.observeFieldScoped("state", "onPlayerStateChanged")
end sub
'-------------------------------------------------------------
sub onPlayerPositionChanged(obj)
	? "Player Position: ", obj.getData()
    
end sub
'-------------------------------------------------------------
sub onPlayerStateChanged(obj)
state = obj.getData()
? "onPlayerStateChanged: ";state

if state="error"
		showErrorDialog(m.videoplayer.errorMsg+ chr(10) + "Error Code: "+m.videoplayer.errorCode.toStr())
	else if state = "finished"
		closeVideo()
	end if
	
end sub
'-------------------------------------------------------------
sub closeVideo()
	m.videoplayer.control = "stop"
	m.videoplayer.visible=false
	m.overhang.visible=true
    m.theRowList.visible=true
    m.theRowList.setFocus(true)
end sub
'-------------------------------------------------------------
sub showErrorDialog(message)
	m.error_dialog.title = "ERROR"
	m.error_dialog.message = message
	m.error_dialog.visible=true
	'tell the home scene to own the dialog so the remote behaves'
	m.top.dialog = m.error_dialog
end sub

'-------------------------------------------------------------
function onKeyEvent(key, press) as Boolean
	? "[slinglikesene] onKeyEvent", key, press
	if key = "up" and press
		if m.theRowList.hasFocus()
			m.postergrid.setfocus(true)
			return true
		
			
		end if
	end if
    if key = "down" and press
		if m.postergrid.hasFocus()
			m.theRowList.setfocus(true)
            
			return true
		
			
		end if
	end if
  if key = "back" and press 
      if m.videoplayer.visible
			m.videoplayer.visible=false
            m.therowlist.visible=true
            m.postergrid.visible=true
            m.theRowList.setFocus(true)
            closeVideo()
			return true
  end if
  end if
  if key = "OK" and press 
 ' print "inside video buffering"
 'code not working . Check it out and fix
      if m.videoplayer.visible
          print "inside video buffering"
			m.videoplayer.bufferingBar.visible = true
            m.videoplayer.TrickPlayBar.visible = true
			return true
  end if
  end if
  return false
end function