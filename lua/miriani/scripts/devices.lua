-- @module devices
-- Device sounds and notifications

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   name="MessageBoardNewMessage"
   group="devices"
   match="^A.+message board reader beeps quietly, indicating to you that there is a new message.+\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/newPost")</send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardToggle"
   group="devices"
   match="^A.+message board reader will (now|no longer) notify you of new messages\.$"
   regexp="y"
   send_to="12"
  >
  <send>if "%1" == "now" then
    mplay("miriani/device/activate")
  else
    mplay("miriani/device/deactivate")
  end
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardUnreadPosts"
   group="devices"
   match="^(There are new messages in.+\.|A.+message board reader beeps urgently, notifying you that there are new messages in .+\.)$"
   regexp="y"
   send_to="12"
  >
  <send>play("miriani/device/UnreadPosts.ogg")</send>
  </trigger>

</triggers>
]=])
