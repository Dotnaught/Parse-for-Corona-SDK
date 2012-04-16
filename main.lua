local Parse = require("parse")

local function main()
	

local function fieldHandler( event )
        
        if ( "began" == event.phase ) then
		print ("Began")
		
                -- This is the "keyboard has appeared" event
                -- In some cases you may want to adjust the interface when the keyboard appears.
        
        elseif ( "ended" == event.phase ) then
                -- This event is called when the user stops editing a field: for example, when they touch a different field
		print ("Ended")
        
        elseif ( "submitted" == event.phase ) then
                -- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
                  
                print( "TextField Object is: " .. tostring( event.target.text ) )

				if (event.target.name == "nameField") then
					Parse.AccountSetup.username = nameField.text
					  if (not nameField.text:match("[^A-Za-z0-9]")) then
						print ("Writing:" .. nameField.text)
					  --write username to DocumentsDirectory, overwriting previous files
					  local path = system.pathForFile( "usr.txt", system.DocumentsDirectory ) 
	                  local file = io.open( path, "w" ) 
		              file:write(event.target.text)
	                  io.close( file )
					  else
					  print("Name format error")
					  end
				elseif (event.target.name == "passwordField") then
					Parse.AccountSetup.password = passwordField.text
					
				elseif (event.target.name == "emailField") then
					--check for email address formatting
					if (event.target.text:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then	
					Parse.AccountSetup.email = emailField.text
					else
					print ("Email format error")
					end
				
				elseif (event.target.name == "updateField") then
						Parse.updateData["credits"] = tonumber(updateField.text)
						print ("updateData: ", Parse.updateData["credits"])
					
				end
					
                  -- Hide keyboard
                  native.setKeyboardFocus( nil )
				
				--copy login info to LocalAccount
				if (Parse.AccountSetup.username and Parse.AccountSetup.password and Parse.AccountSetup.email) then
				Parse.LocalAccount.username = Parse.AccountSetup.username
				Parse.LocalAccount.password = Parse.AccountSetup.password
				Parse.LocalAccount.email = Parse.AccountSetup.email
				end
        end
  
        return true
 
end     


    local nameLabel = display.newText ( "Name:", 10, 292, native.systemFontBold, 12)
    local passwordLabel = display.newText ( "Password:", 10, 332, native.systemFontBold, 12)
    local emailLabel = display.newText ( "Email:", 10, 372, native.systemFontBold, 12)
	local updateLabel = display.newText ( "Update:", 10, 412, native.systemFontBold, 12)
 
    nameField = native.newTextField( 80, 280, 180, 30)
    nameField:addEventListener("userInput", fieldHandler)
    nameField.inputType = "default"
    nameField.name = "nameField"

   	passwordField = native.newTextField( 80, 320, 180, 30)
    passwordField:addEventListener("userInput", fieldHandler)
    passwordField.inputType = "default"
	passwordField.isSecure = true
	passwordField.name = "passwordField"

   	emailField = native.newTextField( 80, 360, 180, 30)
    emailField:addEventListener("userInput", fieldHandler)
    emailField.inputType = "email"
	emailField.name = "emailField"
	
	updateField = native.newTextField( 80, 400, 180, 30)
    updateField:addEventListener("userInput", fieldHandler)
    updateField.inputType = "update"
	updateField.name = "updateField"






end

main()